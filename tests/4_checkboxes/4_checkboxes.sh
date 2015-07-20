tmux send-keys -t $testname:0 "vim -u vimrc.tests $testdir/$testname.wt" C-m
sleep 2
tmux send-keys -t $testname:0 "lG,,cx"
sleep 2
tmux send-keys -t $testname:0 ^[
sleep 2
