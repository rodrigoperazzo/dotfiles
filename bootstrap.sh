#!/usr/bin/env bash
#
# bootstrap installs things.
#
# This script was "forked" from holman/dotfiles.

DOTFILES_ROOT=$(pwd -P)

set -e

echo ''

info () {
  printf "\r  [ \033[00;34m..\033[0m ] %s\n" "$1"
}

user () {
  printf "\r  [ \033[0;33m??\033[0m ] %s\n" "$1"
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] %s\n" "$1"
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] %s\n" "$1"
  echo ''
  exit
}

link_file () {
  local src=$1 dst=$2

  local overwrite='' backup='' skip=''
  local action=''

  if [ -f "$dst" ] || [ -d "$dst" ] || [ -L "$dst" ]
  then
    if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]
    then
      local currentSrc=''
      currentSrc=$(readlink "$dst")

      if [ "$currentSrc" == "$src" ]
      then

        skip=true;

      else

        user "File already exists: $dst ($(basename "$src")), what do you want to do?\n\
        [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
        read -r -n 1 action

        case "$action" in
          o )
            overwrite=true;;
          O )
            overwrite_all=true;;
          b )
            backup=true;;
          B )
            backup_all=true;;
          s )
            skip=true;;
          S )
            skip_all=true;;
          * )
            ;;
        esac

      fi

    fi

    overwrite=${overwrite:-$overwrite_all}
    backup=${backup:-$backup_all}
    skip=${skip:-$skip_all}

    if [ "$overwrite" == "true" ]
    then
      rm -rf "$dst"
      success "removed $dst"
    fi

    if [ "$backup" == "true" ]
    then
      mv "$dst" "${dst}.backup"
      success "moved $dst to ${dst}.backup"
    fi

    if [ "$skip" == "true" ]
    then
      success "skipped $src"
    fi
  fi

  if [ "$skip" != "true" ]  # "false" or empty
  then
    ln -s "$1" "$2"
    success "linked $1 to $2"
  fi
}


install_dotfiles () {
  info 'installing dotfiles'

  local overwrite_all=false backup_all=false skip_all=false

  for src in $(find -H "$DOTFILES_ROOT" -type f -name '.[^.]*')
  do
    if [ "$ui" == "true" ] && [[ "$src" == *\.bash* ]]; then
        info 'skipping bash files for custom terminal ui'
    elif [ "$ui" != "true" ] && [[ "$src" == *\.zsh* ]]; then
        info 'skipping zsh files for regular terminal ui'
    else
        dst="$HOME/$(basename "$src")"
        link_file "$src" "$dst"
    fi
  done
}

install_vmoptions () {
    info 'installing android studio options'

    local overwrite_all=false backup_all=false skip_all=false
    local vmoptions_file="studio.vmoptions"

    if [ "$(uname -s)" == "Darwin" ]
    then
        studio_dir="$HOME/Library/Preferences"
        studio_name="AndroidStudio*"
    else
        studio_dir="$HOME"
        studio_name=".AndroidStudio*"
        if [ "$(uname -m)" == "x86_64" ]
        then
            vmoptions_file="studio64.vmoptions"
        fi
    fi

    # creates a link only to the most recent studio
    studio_prefs=$(find -H "$studio_dir" -maxdepth 1 -type d -name "$studio_name")
    studio_last_version=$(echo "$studio_prefs" | sort -r | head -1)

    if [ ! -z "$studio_last_version" ]
    then
        link_file "$DOTFILES_ROOT/studio.vmoptions" "$studio_last_version/$vmoptions_file"
    fi
}

install_vundle () {
    info 'installing vim vundle'

    if [ ! -d ~/.vim ]; then
        mkdir ~/.vim
    fi

    if [ ! -d ~/.vim/bundle/Vundle.vim ]
    then
        git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
        success 'cloned vim vundle'
    else
        success 'skipped vim vundle'
    fi

    # Execute Vundle plugin to install all plugins added
    vim +PluginInstall +qall
}

install_custom_ui (){
    info 'installing custom terminal ui'

    local overwrite_all=false backup_all=false skip_all=false

    projects="$HOME/Projects"
    if [ ! -d "$projects" ]; then
        mkdir "$projects"
    fi

    if [ ! -d "$projects/oh-my-zsh" ]; then
        # clone oh-my-zsh
        export ZSH="$projects/oh-my-zsh"
        git clone git://github.com/robbyrussell/oh-my-zsh.git "$projects/oh-my-zsh"

        # change the default shell
        chsh -s /bin/zsh

        success 'cloned oh-my-zsh'
    else
        success 'skipped oh-my-zsh'
    fi

    # solarized themes
    if [ ! -d "$projects/solarized" ]; then
        git clone https://github.com/altercation/solarized.git "$projects/solarized"
        success 'cloned solarized'
    else
        success 'skipped solarized'
    fi

    # vim
    if [ ! -d "$HOME/.vim/colors" ]; then
        mkdir -p "$HOME/.vim/colors"
    fi
    link_file "$projects/solarized/vim-colors-solarized/colors/solarized.vim" "$HOME/.vim/colors/solarized.vim"

    # powerline fonts
    if [ ! -d "$projects/powerline-fonts" ]; then
        git clone https://github.com/powerline/fonts.git "$projects/powerline-fonts"
        bash "$projects/powerline-fonts/install.sh"
        success 'cloned powerline-fonts'
    else
        success 'skipped powerline-fonts'
    fi
}

ui=false
case $1 in
    -u | --ui)
        ui=true
        ;;
esac

if [ "$ui" == "true" ]; then
    install_custom_ui
fi
install_dotfiles
install_vmoptions
install_vundle
install_custom_ui

echo ''
echo '  All installed!'

