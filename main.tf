provider "aws" {
  region = "us-east-1"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda-benchmark-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Para cold start: Adicione permissões para invocar via CLI ou adicione API Gateway, mas para teste, use aws lambda invoke
# Para zip: Crie zips manualmente ou use terraform archive_file

data "archive_file" "python_zip" {
  type        = "zip"
  source_dir  = "${path.module}/python"
  output_path = "python.zip"
}

resource "aws_lambda_function" "python" {
  function_name = "benchmark-python"
  role          = aws_iam_role.lambda_role.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.12"
  filename      = data.archive_file.python_zip.output_path
  source_code_hash = data.archive_file.python_zip.output_base64sha256
  memory_size   = 1024
  timeout       = 60
  # Para psutil em Lambda: Inclua como layer ou no zip (instale em python/ via pip install -t python/ psutil)
}

# Similar para outros: Adicione archive_file para cada

data "archive_file" "nodejs_zip" {
  type        = "zip"
  source_dir  = "${path.module}/nodejs"
  output_path = "nodejs.zip"
}

resource "aws_lambda_function" "nodejs" {
  function_name = "benchmark-nodejs"
  role          = aws_iam_role.lambda_role.arn
  handler       = "main.handler"
  runtime       = "nodejs20.x"
  filename      = data.archive_file.nodejs_zip.output_path
  source_code_hash = data.archive_file.nodejs_zip.output_base64sha256
  memory_size   = 1024
  timeout       = 60
}

data "archive_file" "java_zip" {
  type        = "zip"
  source_file = "${path.module}/java/target/lambda-benchmark-1.0-SNAPSHOT.jar"  # ajuste o nome do JAR
  output_path = "java.zip"
}

resource "aws_lambda_function" "java" {
  function_name    = "benchmark-java"
  role             = aws_iam_role.lambda_role.arn
  handler          = "Handler::handleRequest"   # package.class::method  (sem pacote → Handler::handleRequest)
  runtime          = "java21"
  filename         = data.archive_file.java_zip.output_path
  source_code_hash = data.archive_file.java_zip.output_base64sha256
  memory_size      = 1024
  timeout          = 60
}

data "archive_file" "go_zip" {
  type        = "zip"
  source_file = "${path.module}/go/bootstrap"  # Build go: GOOS=linux GOARCH=amd64 go build -o bootstrap main.go
  output_path = "go.zip"
}

resource "aws_lambda_function" "go" {
  function_name = "benchmark-go"
  role          = aws_iam_role.lambda_role.arn
  handler       = "bootstrap"
  runtime       = "provided.al2023"
  filename      = data.archive_file.go_zip.output_path
  source_code_hash = data.archive_file.go_zip.output_base64sha256
  memory_size   = 1024
  timeout       = 60
  architectures = ["x86_64"]  # ou arm64
}

data "archive_file" "dotnet_zip" {
  type        = "zip"
  source_dir  = "${path.module}/dotnet/publish"  # ou onde ficar o publish
  output_path = "dotnet.zip"
}

resource "aws_lambda_function" "dotnet" {
  function_name    = "benchmark-dotnet"
  role             = aws_iam_role.lambda_role.arn
  handler          = "dotnet::Program::Main"   # assemblyName::Namespace.Class::Method (se projeto chama dotnet.csproj → assembly dotnet.dll)
  runtime          = "dotnet10"                # ← ESSA É A MUDANÇA PRINCIPAL!
  filename         = data.archive_file.dotnet_zip.output_path
  source_code_hash = data.archive_file.dotnet_zip.output_base64sha256
  memory_size      = 1024
  timeout          = 60
  architectures    = ["x86_64"]  # ou ["arm64"] se preferir Graviton (melhor cold start em .NET 10)
}