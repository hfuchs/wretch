# (Gotta give 'em a bit of time so I can watch if necessary!)
tmux send-keys -t $testname:0 "vim -u vimrc.tests $testdir/$testname.wt" C-m
sleep 2
tmux send-keys -t $testname:0 "5G,,j" C-g "7G,,j" C-g "10G,,j" C-g "13G,,j" C-g
sleep 2
# 2014-07-19, New tests after the break.
tmux send-keys -t $testname:0 "17Gf>,,j" C-g
sleep 2
tmux send-keys -t $testname:0 ":messages" C-m
sleep 2
