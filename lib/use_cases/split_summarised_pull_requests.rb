module UseCases
  class SplitSummarisedPullRequests
    def execute(pull_request:)
      return pull_request if one_gem_bumped?(pull_request)

      gems_from_title(pull_request[:title]).map do |gem|
        pull_request.merge(title: "Bump #{gem.strip}")
      end
    end

  private

    SINGLE_GEM_TITLE_MATCH = 'Bump \S+ from \S+ to \S+'.freeze

    def one_gem_bumped?(pull_request)
      pull_request[:title].match?(SINGLE_GEM_TITLE_MATCH)
    end

    def gems_from_title(title)
      title.sub('Bump ', '').sub('and', ',').split(',')
    end
  end
end
