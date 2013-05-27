install:
	install -D ftplugin/wretch.vim ~/.vim/ftplugin/wretch.vim
	install -D ftdetect/wretch.vim ~/.vim/ftdetect/wretch.vim
	install -D syntax/wretch.vim   ~/.vim/syntax/wretch.vim
	install -D doc/wretch.txt      ~/.vim/doc/wretch.txt

uninstall:
	rm ~/.vim/*/wretch.vim ~/.vim/doc/wretch.txt

test:
	sh run_tests

