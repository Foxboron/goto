#!/bin/bash
. bin/_gotoutils # load common utils 
     
INSTALL_DIR=/usr/local/opt/goto


function should_be_sudo_on_linux {
    if [[ "$(uname)" == "Linux" && -z $SUDO_USER ]]; then
        echo "On linux this install script needs to run with sudo"
        echo "Run again like this:" 
        echo
        echo "  sudo ./install.sh"
        exit 1
    fi
}


function should_be_admin_on_windows {
    # Detect admin in windows
    if [[ ! -z $(env | grep SESSIONNAME) ]]; then
        echo "On windows using git bash, install must be run as admin"
        echo "Right click git bash and start in admin mode to try again"
        exit 1
    fi
}


function chmod_goto_folder {
    # If run by sudo, chown folders from root to user
    USER=$(logname)
    if [ -n "$SUDO_USER" ]; then
        chown -R $USER:$USER "${HOME}/.goto" || check_status
    fi
}

# Step 0: on linux, be sudo. on windows be admin.
PLATFORM=$(uname -s)
case "$PLATFORM" in
    Linux*)   should_be_sudo_on_linux;;
    CYGWIN*)  should_be_admin_on_windows;;
    MINGW*)  should_be_admin_on_windows;;
esac


echo Step 1: Installing goto into $INSTALL_DIR 
mkdir -p $INSTALL_DIR || check_status
cp -r . $INSTALL_DIR  || check_status



echo Step 2: Adding symlinks to /usr/local/bin
ln -s $INSTALL_DIR/bin/* /usr/local/bin/ 
if [[ "$?" -ne 0 ]]; then
    echo "Failed to symlink to /usr/local/bin"

    if prompt "want to try /usr/bin instead? [y|n]"; then

        echo "Adding symlinks to /usr/bin"
        ln -s $INSTALL_DIR/bin/* /usr/bin/ || check_status
    fi
fi

# Step 2.5 - if running sudo, get original users home
if [ -n "$SUDO_USER" ]; then
        HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
fi




echo Step 3: Setting up magic data folder in ${HOME}/.goto
MAGICPATH="${HOME}/.goto"
if [[ ! -d "$MAGICPATH" ]]; then
    mkdir "${HOME}/.goto" || check_status
    mkdir "${HOME}/.goto/projects" || check_status
    touch "${HOME}/.goto/active-project" || check_status

    # If run by sudo, chown folders from root to user
    chmod_goto_folder
fi

# add init_script to.bash_profile:


if [ -f "${HOME}/.bash_profile" ]; then
    echo 
    echo "Next step is required to make goto work:"
    echo

    if prompt "Add goto startup script to .bash_profile? [y|n]: "; then
        echo
        echo "source start_goto" >> "${HOME}/.bash_profile" || check_status
    else
    echo   
    echo "If you want to do this manually add the line 'source start_goto' to your .bash_profile"
    fi
else
    echo "~/.bash_profile does not exist"
    echo 
    echo "To make goto function properly, add this line to your bash config file: "
    echo
    echo "         source start_goto"
    echo
    echo "into one of these (.bashrc | .profile | .bash_profile)"

    if prompt "Want to append to .bashrc? [y|n]: "; then
        echo "source start_goto" >> "${HOME}/.bashrc" || check_status
    fi

fi


# make goto ready -- now.
source start_goto || check_status

# add your first project
project add goto || check_status

# set the context to this project
project goto

# add your first shortcuts
goto add code "$INSTALL_DIR" || check_status
goto add goto https://github.com/technocake/goto
goto add github https://github.com/technocake/goto

# If run by sudo, chown folders from root to user
chmod_goto_folder 

echo Installation Succesful!
