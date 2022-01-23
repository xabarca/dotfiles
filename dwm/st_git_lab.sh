#! /bin/sh

#BASE_DIR=/tmp/temp_st
BASE_DIR=/opt/git_projects
PROJECT="st"
#DIR_OFFICIAL_DIFFS=/opt/git/dotfiles/patches
DIR_OFFICIAL_DIFFS=~/git/dotfiles/patches
DIR_GENERATED_DIFFS=~

suckCleanMaster() {
	git checkout master
    make clean && rm -f config.h && git reset --hard origin/master
}

generateLocalUserConfig() {
    git config user.name "xavi"
    git config user.email "xavi@devuanfans.org"
}

gotoDir() {
    cd $BASE_DIR/$PROJECT
}

getOwnDiffFile() {
	module=$1
	echo "$DIR_OFFICIAL_DIFFS/$(ls $DIR_OFFICIAL_DIFFS | grep $PROJECT | grep $module | grep my-own)"
}

cloneRepo() {
    [ ! -d $BASE_DIR ] && mkdir -p $BASE_DIR
    cd $BASE_DIR
    yes | rm -r $PROJECT
    git clone --depth 1 git://git.suckless.org/st $BASE_DIR/$PROJECT
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
	
    createBranchByPatch scroll 
    createBranchByPatch alpha-xresources
    createBranchByPatch clipboard
}

mergeManually() {
    gotoDir
    suckCleanMaster

    if git show-ref --quiet refs/heads/allcustom; then
		git branch -D allcustom
	fi
    git branch allcustom
    git checkout allcustom
    
    echo "[*] ------- merging scroll..."
    git merge scroll -m scroll
    echo "[*] ------- merging alpha-xresources..."
    git merge alpha-xresources -m alpha-xresources 
    echo "[*] ------- merging clipboard..."
    git merge clipboard -m clipboard 
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

