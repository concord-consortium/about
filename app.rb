require 'open-uri'

set :haml, :format => :html5 # default Haml format is :xhtml

helpers do
  def nsdl_info(app)
    app_xml = open("http://ncs.concord.org/ncs/services/oai2-0?verb=GetRecord&metadataPrefix=lar&identifier=#{app}").read
    return app_xml
  end
end

get '/:app' do
  @app = params[:app]
  @app_info = nsdl_info(@app)
  haml :index
end
