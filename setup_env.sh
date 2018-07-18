#!/bin/sh

# To run sctip:
# chmod a+x setup_env.sh
# ./setup_env.sh

echo "Hello, this script will install the dev environment for Trinidad"
echo "Please note the questions and follow the instructions that is given"
echo "stay tuned..."
sleep 1

# --------------------- Ask questions first
echo "Is '$(id -F)' your name?"
echo "(press enter to accept or enter new name)"
read tName
if [ -z "$tName" ]
then
  tName="$(id -F)"
fi

echo "Is '$(id -F | tr '[:upper:]' '[:lower:]' | tr ' ' '.')@svenskaspel.se' your email account?"
echo "(press enter to accept or enter new email)"
read tEmail
if [ -z "$tEmail" ]
then
  tEmail="$(id -F | tr '[:upper:]' '[:lower:]' | tr ' ' '.')@svenskaspel.se"
fi

# --------------------- Start installation
echo "The script will now install the dev environment for Trinidad"
sleep 2

# Install Xcode CLT
echo "Installing Xcode Command Line Tools"
xcode-select --install

echo "!!! Script paused, follow on screen instructions"
read -rsp $'Press [enter] to continue when installation is done...\n'

# Install Xcode
# echo "Open AppStore and install Xcode, open it and agree to the license"
# open -a App\ Store
# read -rsp $'Press [enter] to continue when installation is done...\n'

# --------------------- Setup network search domains
# list: networksetup -listallnetworkservices
echo "Set search domains for Thunderbolt Ethernet"
networksetup -setsearchdomains "Thunderbolt Ethernet" int.svenskaspel.se horisont.svenskaspel.se sbg.svenskaspel.se vby.svenskaspel.se ad.spel.se vby.spel.se test.spel.se wlanvby.spenskaspel.se test.svenskaspel.se wifivby.svenskaspel.se wifi.vby.svenskaspel.se sln.spel.se sln.svenskaspel.se
echo "Set search domains for WiFi"
networksetup -setsearchdomains Wi-Fi int.svenskaspel.se horisont.svenskaspel.se sbg.svenskaspel.se vby.svenskaspel.se ad.spel.se vby.spel.se test.spel.se wlanvby.spenskaspel.se test.svenskaspel.se wifivby.svenskaspel.se wifi.vby.svenskaspel.se sln.spel.se sln.svenskaspel.se

# --------------------- Install packages and applications
echo "Installing packages and applications"

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
sudo chown -R $(whoami) /usr/local/var/homebrew
sudo chown -R $(whoami) /usr/local/lib/pkgconfig /usr/local/share/man

brew doctor
brew update

# Install packages
#brew install autoconf
#brew install automake
brew install git
#brew install pcre
brew install chromedriver
brew install git-flow
# if installation of git-flow don't work:
# (rm -rf $(brew --cache git-flow))
brew install node
brew install openssl
brew install pkg-config
brew install rbenv
brew install ruby-build

# Install applications
brew tap caskroom/cask
#brew install caskroom/cask/brew-cask

#brew cask install atom
#brew cask install microsoft-lync
brew cask install rocket-chat
brew cask install sourcetree
brew cask install firefox
brew cask install google-chrome
brew cask install webstorm
#brew cask install rubymine
#brew cask install vmware-fusion

# Cleanup
brew cask cleanup
brew cleanup

# --------------------- Install dev specific stuff
# Install latest node version
sudo npm install -g n
sudo n lts

# GIT setup
echo "Configuring git"
git config --global user.name "$tName"
git config --global user.email "$tEmail"
git config --global core.editor "nano"
git config --global core.ignorecase false

git config --list

# Create folder setup
echo "Creating workspace directory (~/ws/git)"
mkdir -p ~/ws/git
cd ~/ws/git

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles YES
killall Finder

# Generate SSH keys
echo "NOTE: the script assumes that you use the default file location (~/.ssh/id_rsa)"
ssh-keygen -t rsa -b 4096 -C "$tEmail"
eval "$(ssh-agent -s)"
ssh-add -K ~/.ssh/id_rsa

pbcopy < ~/.ssh/id_rsa.pub
echo "!!!!!!"
echo "Visit https://git.svenskaspel.se and sign in (CMD + click to open link)"
echo "1. Click profile settings (upper right)"
echo "2. Click SSH Keys in menu (at left)"
echo "3. Click Add SSH Key"
echo "4. Paste the key that has been copied to your clipboard and choose a good name eg. 'VBY[name] Mac'"

read -rsp $'Press [enter] to continue...\n'

# Test SSH connection
echo "Tesing SSH connection"
ssh -qT git@git.svenskaspel.se
if [ $? != 0 ]
then
  echo "Check fingerprint for equality"
  read -rsp $'Press [enter] to continue...\n'
  ssh -T git@git.svenskaspel.se
fi

# Checkout the code
echo "Cloning Trinidad git repo"
git clone git@git.svenskaspel.se:node/trinidad.git
cd trinidad

# Check for develop and master branches
# If missing, checkout master and/or develop
git checkout master
git checkout develop

# Setup git-flow
echo "Initializing git-flow"
echo "(press [enter] on all questions)"
git-flow init

# Set domains in hosts
echo "Creating entry for test1, test2 and test3 in hosts file"
sudo sh -c "echo '127.0.0.1      local.www.test1.svenskaspel.se' >> /private/etc/hosts"
sudo sh -c "echo '127.0.0.1      local.www.test2.svenskaspel.se' >> /private/etc/hosts"
sudo sh -c "echo '127.0.0.1      local.www.test3.svenskaspel.se' >> /private/etc/hosts"
dscacheutil -flushcache

# --------------------- GUI test
#echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
#export PATH="$HOME/.rbenv/bin:$PATH"
# TODO Restart terminal
#rbenv install 2.1.0
#rbenv global 2.1.0
#rbenv exec gem install bundler
#rbenv rehash
#cd trinidad/test_gui
#rbenv exec bundle install
#gem install thrift -- --with-cppflags=\"-D_FORTIFY_SOURCE=0 -Wno-shift-negative-value\"

# https://github.com/reactioncommerce/reaction/issues/1938
# $ echo kern.maxfiles=65536 | sudo tee -a /etc/sysctl.conf
# $ echo kern.maxfilesperproc=65536 | sudo tee -a /etc/sysctl.conf
# $ sudo sysctl -w kern.maxfiles=65536
# $ sudo sysctl -w kern.maxfilesperproc=65536
# $ ulimit -n 65536

# --------------------- Set num of opened files limit
echo "Updating system max opened files limit"
sudo sh -c "echo '<?xml version=\"1.0\" encoding=\"UTF-8\"?> \
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\"> \
<plist version=\"1.0\"> \
  <dict> \
    <key>Label</key> \
    <string>limit.maxfiles</string> \
    <key>ProgramArguments</key> \
    <array> \
      <string>launchctl</string> \
      <string>limit</string> \
      <string>maxfiles</string> \
      <string>524288</string> \
      <string>524288</string> \
    </array> \
    <key>RunAtLoad</key> \
    <true/> \
    <key>ServiceIPC</key> \
    <false/> \
  </dict> \
</plist>' > /Library/LaunchDaemons/limit.maxfiles.plist"

sudo sh -c "echo '<?xml version=\"1.0\" encoding=\"UTF-8\"?> \
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\"> \
<plist version=\"1.0\"> \
  <dict> \
    <key>Label</key> \
      <string>limit.maxproc</string> \
    <key>ProgramArguments</key> \
      <array> \
        <string>launchctl</string> \
        <string>limit</string> \
        <string>maxproc</string> \
        <string>2048</string> \
        <string>2048</string> \
      </array> \
    <key>RunAtLoad</key> \
      <true /> \
    <key>ServiceIPC</key> \
      <false /> \
  </dict> \
</plist>' > /Library/LaunchDaemons/limit.maxproc.plist"

sudo chown root:wheel /Library/LaunchDaemons/limit.maxfiles.plist
sudo chown root:wheel /Library/LaunchDaemons/limit.maxproc.plist

sudo launchctl load -w /Library/LaunchDaemons/limit.maxfiles.plist
sudo launchctl load -w /Library/LaunchDaemons/limit.maxproc.plist

# Make finish
echo "Running make finish"
make finish

echo "\n\nDONE!"
echo "\nPlease visit https://jive/docs/DOC-4599#jive_content_id_4_Kra_Trinidad (step 4) and follow the instructions to setup Webstorm (CMD + click to open link)"
