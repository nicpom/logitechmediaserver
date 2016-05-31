LMS_LATEST=$(shell wget -O - -q "http://www.mysqueezebox.com/update/?version=7.9.0&revision=1&geturl=1&os=deb")
TAG=$(shell echo $(LMS_LATEST) | sed -e s/[^_]*_// | sed -e s/_all.deb//)
USER=justifiably

build:
	docker build -t $(USER)/logitechmediaserver:$(TAG) .
	docker tag $(USER)/logitechmediaserver:$(TAG) $(USER)/logitechmediaserver:latest
