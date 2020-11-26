#!/run/current-system/profile/bin/bash

pushd $HOME || exit

printf "* install emacs 28 + extras from guix"
printf "** ensure emacs manifest files exist at =~/emacs-manifests="
[ ! -e "$HOME/emacs-manifests" ] \
    && git clone https://github.com/branjam4/guix-bigspec.git emacs-manifests
printf "** make =emacs-profile.sh= executable"
pushd emacs-manifests || return
chmod +777 emacs-profile.sh
./emacs-profile.sh
popd || return

printf "* ensure chemacs; install to ~/.emacs"
printf "Checking for Chemacs- a profile switcher for emacs...\n#+BEGIN_EXAMPLE"
[ ! -e "$HOME/chemacs" ] && git clone https://github.com/plexus/chemacs.git
pushd chemacs || return
chmod +777 install.sh
./install.sh
popd || return

printf "#+END_EXAMPLE\n* clear =.emacs.d=, replace with doom install\n#+BEGIN_EXAMPLE"
printf "#+BEGIN_EXAMPLE\nRemoving ~/.emacs.d"
mv ~/.emacs.d ~/.emacs.d.old
printf "using a git worktree to put an exwm-specific doom in =~/.emacs.d=..."
[ ! -e "$HOME/doom-emacs" ] && git clone https://github.com/hlissner/doom-emacs.git
pushd doom-emacs || return
git worktree add ../.emacs.d origin/develop
printf "Done.\n#+END_EXAMPLE\n"
popd || return
popd || return

printf "* clone exwm config\n#+BEGIN_EXAMPLE"
printf "Cloning my configuration for exwm-doom in =~/.exwm-doom.d=..."
[ ! -e "$HOME/.exwm-doom.d" ] \
    && git clone https://github.com/branjam4/doom-config.git ~/.exwm-doom.d
printf "** symlink =.emacs-profiles.el= to =~/.emacs-profiles.el="

printf "#+END_EXAMPLE\n* install doom on emacs 27\n#+BEGIN_EXAMPLE"
ln -sf .emacs-profiles.el "$HOME"/.emacs-profiles.el
PATH=/run/current-system/profile/bin:$PATH
DOOMDIR="$HOME"/.exwm-doom.d
"$HOME"/.emacs.d/bin/doom -y install

printf "#+END_EXAMPLE\n*# my doom config\n#+BEGIN_EXAMPLE"
[ ! -e "$HOME/.doom.d" ] \
    && git clone https://github.com/branjam4/doom-config.git ~/.doom.d
export PATH="$HOME"/.guix-extra-profiles/main-emacs/main-emacs/bin
export DOOMDIR="$HOME"/.doom.d

printf "#+END_EXAMPLE\n* use alias to ensure emacs 28 will load from a shell spawned in emacs 27\n#+BEGIN_EXAMPLE"
if ! grep -qF "alias emacs='emacs --with-profile doom28'" "$HOME/.bashrc"; then
    printf "alias emacs='emacs --with-profile doom28'" >> "$HOME/.bashrc"
fi

printf "#+END_EXAMPLE\n* give next steps"
printf "Finished! Run =\"~/doom-emacs/bin/doom -y install\"= to install emacs 28."
printf "/(note: may need to run the command multiple times if async silently fails.)/"

