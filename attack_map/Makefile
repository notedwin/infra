lambda:
	@echo "Starting build for attack_map"
	@echo "Cleaning up Python cache files"
	find ./ -type f -name '*.py[co]' -delete
	find ./ -type d -name '__pycache__' -delete
	@echo "Building lambda package attack_map"
	mkdir -p ./lambda-dist/attack_map
	cp index.py ./lambda-dist/attack_map
	@echo "Installing modules"
	python3 -m pip install -r requirements.txt --no-cache-dir -t ./lambda-dist/attack_map/
	@echo "Compressing package"
	cd lambda-dist/attack_map && zip -r attack_map.zip *

clean:
	rm -rf ./lambda-dist/

quick:
	cp index.py ./lambda-dist/attack_map
	cd lambda-dist/attack_map && zip -r attack_map.zip *

.PHONY: lambda clean