# (Gotta give 'em a bit of time so I can watch if necessary!)
tmux send-keys -t $testname:0 "vim -u vimrc.tests $testdir/$testname.wt" C-m
sleep 2
tmux send-keys -t $testname:0 "5G,,j7G,,j10G,,j"
sleep 2
tmux send-keys -t $testname:0 ":messages" C-m
sleep 2
