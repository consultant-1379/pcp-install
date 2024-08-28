#!/bin/bash


if [ "$2" == "" ]; then
	echo usage: $0 \<Module\> \<Branch\> \<Workspace\>
    	exit -1
else
	versionProperties=install/version.properties
	theDate=\#$(date +"%c")
	module=$1
	branch=$2
	workspace=$3
	userId=$4
   	REASON=$5
	CT=/usr/atria/bin/cleartool
	pkgDir=$PWD/pcp/install/
	rpmFileLocation=$PWD/target/
	pkgReleaseArea=/home/$USER/eniq_events_releases
	
fi

function getReason {
        if [ -n "$REASON" ]; then
        	REASON=`echo $REASON | sed 's/$\ /x/'`
                REASON=`echo JIRA:::$REASON | sed s/" "/,JIRA:::/g`
        else
                REASON="CI-DEV"
        fi
}

function getProductNumber {
        product=`cat $PWD/build.cfg | grep $module | grep $branch | awk -F " " '{print $3}'`
}

function getSprint {
        sprint=`cat $PWD/build.cfg | grep $module | grep $branch | awk -F " " '{print $5}'`
}

function setRstate {

        revision=`cat $PWD/build.cfg | grep $module | grep $branch | awk -F " " '{print $4}'`

        if git tag | grep $product-$revision; then
            build_num=`git tag | grep $revision | wc -l`

            if [ "${build_num}" -lt 10 ]; then
				build_num=0$build_num
			fi
			rstate=`echo $revision$build_num | perl -nle 'sub nxt{$_=shift;$l=length$_;sprintf"%0${l}d",++$_}print $1.nxt($2) if/^(.*?)(\d+$)/';`
		else
            ammendment_level=01
            rstate=$revision$ammendment_level
        fi
        echo "Building R-State:$rstate"

}

function cleanup {
        if [ -d $pkgDir ] ; then
          echo "removing $pkgDir"
          rm -rf $pkgDir
        fi
}

function createTar {
    echo "Copying $rpmFile into $pkgDir"
    cp $rpmFile $pkgDir
    echo "Changing directory to $PWD"
    cd $PWD
    echo "Creating tar - tarring the $PWD/pcp directory"
    tar -czvf $PWD/$pkgName pcp
    echo "Copying $PWD/$pkgName file into $pkgReleaseArea"
    cp $PWD/$pkgName $pkgReleaseArea
}


function runMaven {
    mvn -f $PWD/pom.xml clean assembly:assembly -Drstate=$rstate
    rsp=$?
}


function putRStateIntoFile {
	
	# Creating rstate.txt file to the PCP_Aliases Directory for DEFTFTS-1353
	installRstateFile="core_install/bin/PCP_Aliases/rstate.txt"
	
	echo "Creating a file with the rstate in $PWD/$installRstateFile"
	
	touch $PWD/$installRstateFile
	echo $rstate > $PWD/$installRstateFile
	
	echo "Finished creating a file with the rstate in $PWD/$installRstateFile"
}

cleanup
getSprint
getProductNumber
setRstate
getReason
pkgName="probe_installation_${rstate}.tar.gz"
rpm="pcp_core_install.tar.gz"
git clean -df
git checkout $branch
git pull

putRStateIntoFile

runMaven

mkdir --parent $pkgDir


if [ $rsp == 0 ]; then
  git tag $product-$rstate
  git pull
  git push --tag origin $branch
  rpmFile=$rpmFileLocation/$rpm
  echo "rpm file is $rpmFile "
  echo "Creating tar file..."
  createTar
  touch $PWD/rstate.txt
  echo $rstate >> $PWD/rstate.txt
fi  

if "${Deliver}"; then
    if [ "${DELIVERY_TYPE}" = "SPRINT" ]; then
    $CT setview -exec "/proj/eiffel013_config/fem101/jenkins_home/bin/lxb /vobs/dm_eniq/tools/scripts/deliver_eniq -auto events ${sprint} ${REASON} Y ${BUILD_USER_ID} ${product} NONE $pkgReleaseArea/$pkgName" deliver_ui
else
    $CT setview -exec "/proj/eiffel013_config/fem101/jenkins_home/bin/lxb /vobs/dm_eniq/tools/scripts/eu_deliver_eniq -EU events ${sprint} ${REASON} Y ${BUILD_USER_ID} ${product} NONE $pkgReleaseArea/$pkgName" deliver_ui
    fi
else
   echo "The delivery option was not selected.."
    fi

exit $rsp
