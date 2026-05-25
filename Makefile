RUBYOPT = -Eutf-8:utf-8 -r./yaml_time_patch

.PHONY: build serve

build:
	RUBYOPT="$(RUBYOPT)" bundle exec middleman build

serve:
	RUBYOPT="$(RUBYOPT)" bundle exec middleman server
