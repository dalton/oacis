module ApplicationHelper

  def distance_to_now_in_words(datetime)
    if datetime
      return distance_of_time_in_words_to_now(datetime) + ' ago'
    else
      return ''
    end
  end

  def breadcrumb_links_for(document)
    links = []
    case document
    when Run
      links = breadcrumb_links_for(document.parameter_set)
      links << link_to(document.to_param, run_path(document))
    when ParameterSet
      links = breadcrumb_links_for(document.simulator)
      links << link_to(document.to_param, parameter_set_path(document))
    when Simulator
      links = [ link_to("Simulators", simulators_path) ]
      links << link_to(document.name, simulator_path(document))
    when AnalysisRun
      links = breadcrumb_links_for(document.analyzable)
      links << document.to_param
    when Analyzer
      links = breadcrumb_links_for(document.simulator)
      links << document.name
    else
      raise "not supported type"
    end
    return links
  end

  # to prevent UTF-8 parameter from being added in the URL for GET requests
  # See http://stackoverflow.com/questions/4104474/rails-3-utf-8-query-string-showing-up-in-url
  def utf8_enforcer_tag
    return "".html_safe
  end

end
