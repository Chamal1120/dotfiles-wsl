## My config for WSL2

### Ingredients
1. Windows 11 ( or 10 which supports WSL2)

### Setup
1. Open powershell as admin and install WSL2:
```powershell
wsl --install
```
>NOTE: More info at https://learn.microsoft.com/en-us/windows/wsl/basic-commands#install

2. Install alacritty terminal:
```powershell
winget install -e --id Alacritty.Alacritty
```

3. Log into WSL using windows terminal:

4. Clone this repo:
```bash
git clone https://github.com/chamal1120/dotfiles-wsl.git
```

5. Change into dotfiles-wsl dir:
```bash
cd dotfiles-wsl
```

6. Apply the alacritty configs:
```bash
cp alacritty-windows-config/alacritty.toml /mpt/c/Users/<your-username/Roaming/alacritty
cp alacritty-windows-config/vague.toml /mpt/c/Users/<your-username/Roaming/alacritty
```
>NOTE: Make sure to change <your-username> and create the alacritty folder inside Roaming dir if it is not. 

7. Install GNU-stow:
```bash
sudo apt install stow
```

8. Change into configs:
```bash
cd ../configs
```

9. Apply the terminal configs:
```bash
stow --target=$HOME bash hushlogin nvim p10k scripts tmux zsh
```
