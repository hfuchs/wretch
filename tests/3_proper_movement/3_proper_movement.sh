tmux send-keys -t $testname:0 "vim -u vimrc.tests $testdir/$testname.wt" C-m
sleep 2
tmux send-keys -t $testname:0 "fMdw"
sleep 2
tmux send-keys -t $testname:0 ^[
sleep 2
