#! /bin/sh

BASE_DIR=/tmp/temp_dwm
#BASE_DIR=/opt/git
PROJECT="dwm"
DIR_OFFICIAL_DIFFS=/opt/git/dotfiles/dwm_patches
#DIR_OFFICIAL_DIFFS=~/git/dotfiles/dwm_patches
DIR_GENERATED_DIFFS=~

suckCleanMaster() {
	git checkout master
    make clean && rm -f config.h && git reset --hard origin/master
}

generateLocalUserConfig() {
    git config user.name "xavi"
    git config user.email "xavi@devuanfans.org"
}

gotoDir() {S
    cd $BASE_DIR/$PROJECT
}

getOwnDiffFile() {
	module=$1
	echo "$DIR_OFFICIAL_DIFFS/$(ls $DIR_OFFICIAL_DIFFS | grep $module | grep my-own)"
}

cloneRepo() {
    [ ! -d $BASE_DIR ] && mkdir -p $BASE_DIR
    cd $BASE_DIR
    yes | rm -r $PROJECT
    git clone --depth 1 https://git.suckless.org/dwm $BASE_DIR/$PROJECT
}

createBranchByPatch() {
    branchName=$1
    suckCleanMaster
    git branch $branchName
    git checkout $branchName
    git apply "$(getOwnDiffFile $branchName)"
    git add .
    git commit -m $branchName
}

makeBranches() {
    gotoDir    
	generateLocalUserConfig
	
    createBranchByPatch config
    createBranchByPatch status2dallmons 
    createBranchByPatch pertag
    createBranchByPatch noborder
    createBranchByPatch scratchpad
    createBranchByPatch dwmc
    #createBranchByPatch statusallmons
    createBranchByPatch xresources
    createBranchByPatch attachtop
    createBranchByPatch xrdb
}

mergeManually() {
    gotoDir
    suckCleanMaster

    if git show-ref --quiet refs/heads/allcustom; then
		git branch -D allcustom
	fi
    git branch allcustom
    git checkout allcustom
    
    echo "[*] ------- merging config ..."
    git merge config -m config
    echo "[*] ------- merging pertag ..."
    git merge pertag -m pertag
    echo "[*] ------- merging noborder ..."
    git merge noborder -m noborder
    echo "[*] ------- merging dwmc ..."
    git merge dwmc -m dwmc
    echo "[*] ------- merging attachtop ..."
    git merge attachtop -m attachtop
    echo "[*] ------- merging xrdb ..."
    git merge xrdb -m xrdb
    echo "[*] ------- merging status2dallmons ..."
    git merge status2dallmons -m status2dallmons
}

customRebase() {
    echo "---- init of custom rebase -----"
    gotoDir
    suckCleanMaster
    git branch -D allcustom
    git branch allcustom
    git checkout allcustom
    for branch in $(git for-each-ref --format='%(refname)' refs/heads/ | cut -d'/' -f3); do
	    if [ "$branch" != "master" ] && [ "$branch" != "allcustom" ];then
		    echo $branch
		    git rebase --rebase-merges $branch
	    fi
    done
}

makeDiffs() {
    echo "---- init of makeDiffs -----"
    gotoDir
    suckCleanMaster
    for branch in $(git for-each-ref --format='%(refname)' refs/heads/ | cut -d'/' -f3); do
	    if [ "$branch" != "master" ];then
            git diff master..$branch > "$DIR_GENERATED_DIFFS/my-own-$PROJECT-${branch}_$(date '+%Y%m%d').diff"
            echo "-->> $branch diff generated"
    	fi
    done
}


cloneRepo && makeBranches && mergeManually
#cloneRepo && makeBranches && customRebase

#makeDiffs

echo "done!"

