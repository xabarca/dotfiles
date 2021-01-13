#! /bin/sh

BASE_DIR=/tmp/temp_dwm
#BASE_DIR=/opt/git
PROJECT="dwm"
DIR_OFFICIAL_DIFFS=/opt/git/dotfiles/dwm_patches
#DIR_OFFICIAL_DIFFS=~/git/dotfiles/dwm_patches
DIR_GENERATED_DIFFS=~

suckClean() {
    make clean && rm -f config.h && git reset --hard origin/master
}

gotoDir() {
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
    git clone https://git.suckless.org/dwm $BASE_DIR/$PROJECT
}

createBranchByPatch() {
	branchName=$1
	git checkout master
    suckClean
    git branch $branchName
    git checkout $branchName
    git apply "$(getOwnDiffFile $branchName)"
    git add .
    git commit -m $branchName
}

makeBranches() {
    gotoDir    
    git config user.name "xavi"
	git config user.email "xavi@devuanfans.org"
	
    createBranchByPatch config
    createBranchByPatch pertag
    createBranchByPatch noborder
    createBranchByPatch scratchpad
    createBranchByPatch dwmc
    createBranchByPatch statusallmons
    createBranchByPatch xresources
    createBranchByPatch attachtop
}

mergeManually() {
    gotoDir
    git checkout master
    suckClean
    echo "[*] ------- merging config ..."
    git merge config -m config
    echo "[*] ------- merging pertag ..."
    git merge pertag -m pertag
    echo "[*] ------- merging noborder ..."
    git merge noborder -m noborder
    echo "[*] ------- merging dwmc ..."
    git merge dwmc -m dwmc
    echo "[*] ------- merging statusallmons ..."
    git merge statusallmons -m statusallmons
    echo "[*] ------- merging xresources ..."
    git merge xresources -m xresources
    echo "[*] ------- merging attachtop ..."
    git merge attachtop -m attachtop
}

customRebase() {
    gotoDir
    git checkout master
    suckClean
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
    gotoDir
    git checkout master
    suckClean
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

