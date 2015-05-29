require 'mechanize'
require 'csv'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def uri_valid?(uri)
    return uri[-5..-1].eql?(".html") && uri.include?("Indv") #&& !uri.include?("Detail") && !uri.include?("Sweeps") && !uri.include?("Bowl") && !uri.include?("State")
  end
  def sanitize_path(uri)
    return uri.sub("../Downloadable/Results/","").gsub("/","--")
  end
  # CSV to hash from http://technicalpickles.com/posts/parsing-csv-with-ruby/
  def csv_to_hash(body)
    CSV::Converters[:blank_to_nil] = lambda do |field|
      field && field.empty? ? nil : field
    end
    csv = CSV.new(body, :headers => true, :header_converters => :symbol, :converters => [:all, :blank_to_nil])
    return csv.to_a.map {|row| row.to_hash }
  end

  def index
    agent = Mechanize.new

    resultsHomeURI = "http://famat.org/PublicPages/Results.aspx"
    yearsAvailable = ["2015","2014","2013","2012","2011","2010","2009","2008","2007"]
    yearSelectorDoPostBackVariable = "ctl00$ContentPlaceHolder1$ddlYear"

    resultsHome = agent.get(resultsHomeURI)
    form = resultsHome.forms[0]
    
    # for i in 0..(yearsAvailable.size-1)
    #   form[yearSelectorDoPostBackVariable] = yearsAvailable[i]
    #   resultsHome = form.submit

    #   resultsHome.links_with(:href => /Results/).each do |link|
    #     if uri_valid?(link.href) then
    #       resultsPage = agent.get("http://famat.org/#{link.href[2..-1]}")
    #       sanitized = sanitize_path(link.href)
    #       filename = "app/assets/result_tables/#{sanitized}.csv"

    #       rows = resultsPage.search("/html/body/table//tr")

    #       CSV.open(filename,"wb") do |csv|
    #         rows.each do |row|
    #           csvRow = []
    #           elems = row.search("td")
    #           elems.each do |elem|
    #             csvRow.push(elem.text.strip())
    #           end
    #           csv << csvRow
    #         end
    #       end
    #     else
    #       puts "Found invalid file as result (#{link.href}), continuing"
    #     end
    #   end
    # end

    resultsFolder = "app/assets/result_tables/"

    @filenames = Dir.glob("#{resultsFolder}*")
    @filenames = @filenames.map { |name|
      [name.sub(resultsFolder,"").sub(".html.csv","")[/(.*)--/].sub("--",""),
       name.sub(resultsFolder,"").sub(".html.csv","")[/--(.*)/].sub("--","")]}
    
    @selectedCompetition = ""
    @selectedTest = ""
    render "layouts/application"
  end
end