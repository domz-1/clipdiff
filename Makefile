.PHONY: all install uninstall test
all:
	@echo "Run 'make install' to install ClipDiff"
install:
	@bash ./install.sh
uninstall:
	@bash ./uninstall.sh
