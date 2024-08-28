# .bash_profile
# Get the aliases and functions
if [ -f /eniq/home/dcuser/.bashrc ]; then
	. /eniq/home/dcuser/.bashrc
fi
# User specific environment and startup programs
 PATH=$PATH:$HOME/bin
 export JAVA_HOME="/usr/java/jdk1.7.0_80"
 HQ_JAVA_HOME=$JAVA_HOME
 export HQ_JAVA_HOME
 export PATH
