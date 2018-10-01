shellcheck:
ifeq ($(shell shellcheck > /dev/null 2>&1 ; echo $$?),127)
ifeq ($(shell uname),Darwin)
	brew install shellcheck
else
	sudo add-apt-repository 'deb http://archive.ubuntu.com/ubuntu trusty-backports main restricted universe multiverse'
	sudo apt-get update -qq && sudo apt-get install -qq -y shellcheck
	
	# installs, work.
	RUN apt-get update && apt-get install -y wget --no-install-recommends \
	    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
	    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
	    && apt-get update \
	    && apt-get install -y google-chrome-unstable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst ttf-freefont \
	      --no-install-recommends \
	    && rm -rf /var/lib/apt/lists/* \
	    && apt-get purge --auto-remove -y curl \
	    && rm -rf /src/*.deb
endif
endif

ci-dependencies: shellcheck

lint:
	@echo linting...
	@$(QUIET) find ./ -maxdepth 2 -not -path '*/\.*' | xargs file | egrep "shell|bash" | awk '{ print $$1 }' | sed 's/://g' | xargs shellcheck -e SC2069

setup:
	$(MAKE) ci-dependencies

test: setup lint
