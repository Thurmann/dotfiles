#!/bin/sh

BLUE='\033[0;36m'
NC='\033[0m'

init() {
	echo "${BLUE}Initializing workspace${NC}"
	mkdir -pv ${HOME}/workspace
	echo "${BLUE}Initilizing jetty dir${NC}"
	sh jetty/jetty-init.sh
}

nvim() {
	echo "${BLUE}Configuring LazyVim${NC}"
	echo "Proceed? (y/n)"
	read resp
	if [ "$resp" = 'y' ] || [ "$resp" = 'Y' ]; then
		local script_dir="$(cd "$(dirname "$0")" && pwd)"
		local dotfiles_dir="${script_dir}/../dotfiles"
		local config_dir="${HOME}/.config"
		local nvim_dir="${config_dir}/nvim"
		if [ -d "$nvim_dir" ]; then
			# Rename .config/nvim directory to nvim.{current_timestamp}.bak
			mv "$nvim_dir" "${config_dir}/nvim.$(date +'%Y%m%d%H%M%S').bak"
		else
			mkdir -pv "$config_dir"
			mkdir -pv "$nvim_dir"
		fi
		if [ -d "$dotfiles_dir/nvim" ]; then
			cp -R "$dotfiles_dir/nvim" "$nvim_dir"
			echo "LazyVim config installed"
		else
			echo "Error: LazyVim config directory not found in '$dotfiles_dir/nvim'. Installation failed."
			return 1
		fi
	else
		echo "LazyVim config cancelled"
		return 1
	fi
}

# Symlink $1 to $2, backing up an existing file or directory that is not a symlink
link_file() {
	if [ ! -e "$1" ]; then
		echo "Skipping $2: $1 does not exist"
		return
	fi
	if [ -e "$2" ] && [ ! -L "$2" ]; then
		mv -v "$2" "$2.$(date +'%Y%m%d%H%M%S').bak"
	fi
	ln -svfn "$1" "$2"
}

link() {
	echo "${BLUE}Initializing symlinks${NC}"
	echo "Proceed? (y/n)"
	read resp
	if [ "$resp" = 'y' -o "$resp" = 'Y' ]; then
		mkdir -pv "${HOME}/.config"
		mkdir -pv "${HOME}/.config/fish"
		link_file "$PWD/.aliases" "$HOME/.aliases"
		link_file "$PWD/.bash_profile" "$HOME/.bash_profile"
		link_file "$PWD/.exports" "$HOME/.exports"
		link_file "$PWD/.functions" "$HOME/.functions"
		link_file "$PWD/.vimrc" "$HOME/.vimrc"
		link_file "$PWD/.ideavimrc" "$HOME/.ideavimrc"
		link_file "$PWD/.zprofile" "$HOME/.zprofile"
		link_file "$PWD/.zshenv" "$HOME/.zshenv"
		link_file "$PWD/.zshrc" "$HOME/.zshrc"
		link_file "$PWD/.config/fish/config.fish" "$HOME/.config/fish/config.fish"
		link_file "$PWD/.config/fish/alias.fish" "$HOME/.config/fish/alias.fish"
		link_file "$PWD/.config/fish/export.fish" "$HOME/.config/fish/export.fish"
		link_file "$PWD/.config/fish/completions" "$HOME/.config/fish/completions"
		link_file "$PWD/.config/starship.toml" "$HOME/.config/starship.toml"
		echo "Symlinking complete"
	else
		echo "Symlinking cancelled"
		return 1
	fi
}

install_tools() {
	if [ $(echo "$OSTYPE" | grep 'darwin') ]; then
		echo "${BLUE}Initializing homebrew${NC}"
		echo "Proceed? (y/n)"
		read resp
		if [ "$resp" = 'y' -o "$resp" = 'Y' ]; then
			echo "Installing useful stuff using brew. This may take a while..."
			sh brew-install.sh
		else
			echo "Brew installation cancelled by user"
		fi
	else
		echo "Skipping installations using Homebrew because MacOS was not detected..."
	fi
}

compile_exports() {
	echo "${BLUE}Setting compiled exports${NC}"
	sh compiled-exports.sh
}

set_zsh() {
	echo "${BLUE}Set ZSH to default?${NC} (y/n)"
	read resp
	if [ "$resp" = 'y' -o "$resp" = 'Y' ]; then
		echo "setting shell to zsh"
		chsh -s /usr/local/bin/zsh
	else
		echo "skipping chsh"
	fi
}

oh_my_zsh() {
	echo "${BLUE}Install oh my zsh?${NC} (y/n)"
	read resp
	if [ "$resp" = 'y' -o "$resp" = 'Y' ]; then
		echo "installing oh my zsh"
		sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
		git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
			${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
		git clone https://github.com/zsh-users/zsh-autosuggestions \
			${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
	else
		echo "skipping oh my zsh"
	fi
}

if [ "$1" = "init" ]; then
	init
elif [ "$1" = "symlink" ]; then
	link
elif [ "$1" = "exports" ]; then
	compile_exports
elif [ "$1" = "tools" ]; then
	install_tools
elif [ "$1" = "nvim" ]; then
	nvim
elif [ "$1" = "all" ]; then
	init
	install_tools
	compile_exports
	set_zsh
	oh_my_zsh
	nvim
	link
else
	echo "Usage: $0 {all|init|symlink|exports|tools|nvim}"
fi
