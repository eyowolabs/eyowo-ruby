require_relative './lib/eyowo.rb'

app_key = 'ba65a6b853ff65c4ba2e7be3a2249731'
app_secret = '5eca35d7e47c11b46bd896e417b7b1cea12d529e1b411ffcd4768eda7a7346e0'

Eyowo::init({ app_key: app_key, app_secret: app_secret })
Eyowo::Balance.retrieve({ mobile: '2348184209188' })