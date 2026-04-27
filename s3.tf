resource " aws_s3_bucket " " frontend " {
bucket = "${var . project_name } - frontend -${ data . aws_caller_identity .
current . account_id }"
}
resource " aws_s3_bucket_website_configuration " " frontend " {
bucket = aws_s3_bucket . frontend . id
index_document {
suffix = " index . html "
}
error_document {
key = " index . html "
}
}
resource " aws_s3_bucket_public_access_block " " frontend " {
bucket = aws_s3_bucket . frontend . id
block_public_acls = false
block_public_policy = false
ignore_public_acls = false
restrict_public_buckets = false
}
resource " aws_s3_bucket_policy " " frontend_policy " {
bucket = aws_s3_bucket . frontend . id
policy = jsonencode ({
Version = " 2012 -10 -17 ",
Statement = [
{
Effect = " Allow ",
Principal = "*",
Action = ["s3: GetObject "] ,
Resource = "${ aws_s3_bucket . frontend . arn }/*"
}
]
})
depends_on = [ aws_s3_bucket_public_access_block . frontend ]
}
resource " aws_s3_object " " index_html " {
bucket = aws_s3_bucket . frontend . id
key = " index . html "
content_type = " text / html "
content = << EOFHTML
<! DOCTYPE html >
< html lang ="es">
< head >
< meta charset ="UTF -8">
< title > Laboratorio IaC AWS </ title >
< style >
body { font - family : Arial , sans - serif ; margin : 40 px ; }
button { padding : 10 px 18 px ; }
# resultado { margin -top: 20 px; padding : 12 px; background : # f2f2f2 ;
}
</ style >
</ head >
< button onclick =" consultarAPI ()"> Consultar API </ button >
< div id =" resultado "> Esperando consulta ... </ div >
< script src ="app .js" > </ script >
</ body >
</ html >
EOFHTML
}
resource " aws_s3_object " " app_js " {
bucket = aws_s3_bucket . frontend . id
key = "app.js"
content_type = " application / javascript "
content = << EOFJS
async function consultarAPI () {
const resultado = document . getElementById ( ’ resultado ’) ;
try {
const resp = await fetch ( ’ $ { aws_apigatewayv2_stage . api_stage .
invoke_url }/ items ’) ;
const data = await resp . json () ;
resultado . innerText = JSON . stringify (data , null , 2) ;
} catch ( error ) {
resultado . innerText = ’ Error al consultar API : ’ + error ;
}
}
EOFJS
}
< body >
<h1 > Frontend en S3 </ h1 >
<p > Esta p á gina se aloja como sitio web est á tico en Amazon S3 . </p >
