#custom headers for rally 
headers = RallyAPI::CustomHeader.new()
headers.name = ":=CustomAPITest:"
headers.vendor = "Testing"
headers.version = "Client Test Software"

#Config Parameters
@config = {}
@config[:base_url] = "https://rally1.rallydev.com/slm"
@config[:api_key] = ENV['rally_api_token']
@config[:workspace] = "Personal"
@config[:project] = "Personal-Test"
@config[:headers] = headers

