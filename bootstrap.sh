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
		local dotfiles_dir="${HOME}/workspace/dotfiles"
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

link() {
	echo "${BLUE}Initializing symlinks${NC}"
	echo "Proceed? (y/n)"
	read resp
	if [ "$resp" = 'y' -o "$resp" = 'Y' ]; then
		mkdir -pv "${HOME}/.config"
		mkdir -pv "${HOME}/.config/fish"
		ln -svf "$PWD/.aliases" "$HOME"
		ln -svf "$PWD/.bash_profile" "$HOME"
		ln -svf "$PWD/.exports" "$HOME"
		ln -svf "$PWD/.functions" "$HOME"
		ln -svf "$PWD/.vimrc" "$HOME"
		ln -svf "$PWD/.zshenv" "$HOME"
		ln -svf "$PWD/.zshrc" "$HOME"
		ln -svf "$PWD/.aliases" "$HOME"
		ln -svf "$PWD/.config/fish/config.fish" "$HOME/.config/fish/config.fish"
		ln -svf "$PWD/.config/fish/alias.fish" "$HOME/.config/fish/alias.fish"
		ln -svf "$PWD/.config/fish/export.fish" "$HOME/.config/fish/export.fish"
		ln -svf "$PWD/.config/fish/completions" "$HOME/.config/fish/completions"
		ln -svf "$PWD/.config/starship.toml" "$HOME/.config/starship.toml"
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
