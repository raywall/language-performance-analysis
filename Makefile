.PHONY: prepare header dotnet go java nodejs python run build clean deploy destroy

BUILD_OPTION ?= 0

ifeq ($(findstring run,$(MAKECMDGOALS)),run)
    BUILD_OPTION := 0
endif

# Força DEV_MODE=1 quando o alvo principal é build
ifeq ($(findstring build,$(MAKECMDGOALS)),build)
    BUILD_OPTION := 1
endif

prepare:
	@cd go && go mod tidy
	@cd python && pip3 install psutil
	@cd dotnet && \
	 dotnet add package Amazon.Lambda.Core --version 2.2.0 && \
	 dotnet add package Amazon.Lambda.RuntimeSupport --version 1.10.0 && \
	 dotnet add package Amazon.Lambda.Serialization.SystemTextJson --version 2.4.3

header:
	@if [ "$(BUILD_OPTION)" = "0" ]; then \
		echo "\n========================================================"; 	\
		echo "   BENCHMARK: TEMPO DE EXECUÇÃO VS CONSUMO DE MEMÓRIA   "; 	\
		echo "========================================================";	\
	 else \
		echo "\n========================================================"; 	\
		echo "      BENCHMARK: BUILDING AND GENERATING PACKAGES       "; 	\
		echo "========================================================\n"; 	\
		rm -rf bin/; \
		mkdir -p bin; \
	 fi

dotnet:
	@cd dotnet;	 \
	 rm -rf bin; \
	 if [ "$(BUILD_OPTION)" = "0" ]; then 	\
	 	echo "\n.NET C#"; \
	 	echo "--------------------------------------------------------"; \
		dotnet run --configuration Release; \
	 else \
	 	echo "Building .NET application ..."; \
	 	dotnet clean -c Release > /dev/null; \
		dotnet build dotnet.csproj -c Release > /dev/null; \
	 	dotnet publish dotnet.csproj -c Release -o "../bin/dotnet/" --no-restore --no-build > /dev/null; \
	 fi
	
go:
	@cd go; \
	 if [ "$(BUILD_OPTION)" = "0" ]; then \
		echo "\nGolang"; \
	 	echo "--------------------------------------------------------"; \
		go run main.go; \
	 else \
	 	echo "Building Go application ..."; \
	 	GOOS=linux GOARCH=amd64 go build -o ../bin/bootstrap main.go; \
	 fi

java:
	@cd java && \
	 if [ "$(BUILD_OPTION)" = "0" ]; then \
		echo "\nJava"; \
	 	echo "--------------------------------------------------------"; \
	 	javac -cp aws-lambda-java-core.jar Handler.java; \
	 	java -cp .:aws-lambda-java-core.jar Handler; \
	 else \
	 	echo "Building Java application ..."; \
	 	javac -cp aws-lambda-java-core.jar Handler.java; \
	 	cp Handler.class ../bin/; \
	 fi

nodejs:
	@cd nodejs; \
	 if [ "$(BUILD_OPTION)" = "0" ]; then \
		echo "\nNode.JS"; \
	 	echo "--------------------------------------------------------"; \
	 	node main.js; \
	 else \
	 	echo "Building Node.JS application ..."; \
	 	mkdir -p ../bin/nodejs; \
	 	cp -r . ../bin/nodejs/; \
	 fi

python:
	@cd python; \
	 if [ "$(BUILD_OPTION)" = "0" ]; then \
		echo "\nPython"; \
	 	echo "--------------------------------------------------------"; \
	 	python3 main.py; \
	 else \
	 	echo "Building Python application ..."; \
		mkdir -p ../bin/python; \
		cp main.py ../bin/python/; \
		pip3 install --target ../bin/python --quiet psutil; \
	 fi

run:  header dotnet go java nodejs python
	@echo "========================================================\n"

build: header dotnet go java nodejs python
	@echo "\nGerando zips para Lambda a partir de bin/..."; \
	 cd bin; \
	 zip -q -r dotnet.zip dotnet; \
	 rm -rf dotnet/; \
	 zip -q -r go.zip bootstrap; \
	 rm -rf bootstrap; \
	 zip -q -r java.zip Handler.class; \
	 rm -rf Handler.class; \
	 zip -q -r nodejs.zip nodejs; \
	 rm -rf nodejs/; \
	 zip -q -r python.zip python; \
	 rm -rf python/;

	@echo "Zips gerados em:\n"; \
	 ls -lh bin/*.zip 2>/dev/null || echo "Nenhum zip encontrado (verifique erros acima)"; \
	 echo "\n========================================================\n";

clean:
	@rm -rf bin/; \
	 echo "Pasta bin/ removida.";

deploy:
	@terraform init; \
	 terraform plan -auto-approve; \
	 terraform apply -auto-approve;

destroy:
	@terraform destroy -auto-approve; \
	 rm -rf .terraform* terraform.tfstate;