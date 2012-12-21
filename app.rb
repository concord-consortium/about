require 'open-uri'

set :haml, :format => :html5 # default Haml format is :xhtml

NSDL_INFO_ITEMS = [
  {:key => :lastModified, :tag => "recordDate"},
  {:key => :title, :tag => "title"},
  {:key => :description, :tag => "description"},
  {:key => :subject, :tag => "subject"},
  {:key => :educationLevel, :tag => "educationLevel"},
  {:key => :type, :tag => "type"},
  {:key => :license, :tag => "license"},
  {:key => :copyright, :tag => "copyright"},
  {:key => :creator, :tag => "contributor[role=\"Creator\"]"},
  {:key => :funder, :tag => "contributor[role=\"Funder\"]"},
  {:key => :grantNumber, :tag => "otherIdentifier[type=\"NSF Grant No.\"]"}
]

helpers do
  def extract(rawTag, xml)
    tag = rawTag.sub(/\[(.*?)\]/, '')
    attrs = $1 ? (" " + $1) : ""
    regexp = Regexp.compile("<#{tag}#{attrs}>(.*?)<\/#{tag}>", Regexp::MULTILINE)
    return xml.scan(regexp).flatten.compact.uniq
  end

  def nsdl_info(app)
    app_xml = open("http://ncs.concord.org/ncs/services/oai2-0?verb=GetRecord&metadataPrefix=lar&identifier=#{app}").read
    app_info = {}
    NSDL_INFO_ITEMS.each do |item|
      app_info[item[:key]] = extract(item[:tag], app_xml)
    end
    return app_info
  end

  def funder_names
    out = ""
    @app_info[:funder].each_with_index do |funder, i|
      if i == 0
        out << funder
      elsif i == (@app_info[:funder].size - 1)
        if i == 1
          out << " and #{funder}"
        else
          out << ", and #{funder}"
        end
      else
        out << ", #{funder}"
      end
    end
    return out
  end
end

get '/:app' do
  @app = params[:app]
  @app_info = nsdl_info(@app)
  haml :index
end
