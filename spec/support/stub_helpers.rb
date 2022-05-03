module StubHelpers
  def review_required_url
    "https://api.github.com/search/issues?per_page=100&q=is:pr+user:alphagov+state:open+author:app/dependabot+archived:false+review:required"
  end

  def approved_url
    "https://api.github.com/search/issues?per_page=100&q=is:pr+user:alphagov+state:open+author:app/dependabot+archived:false+review:approved"
  end

  def changes_requested_url
    "https://api.github.com/search/issues?per_page=100&q=is:pr+user:alphagov+state:open+author:app/dependabot+archived:false+review:changes_requested"
  end

  def no_pull_requests_body
    '{"total_count": 0, "incomplete_results": false, "items": [] }'
  end

  def pull_requests_body
    @pull_requests_body ||= File.read("spec/fixtures/pull_requests.json")
  end

  def stub_github_request(request_url, body)
    stub_request(:get, request_url)
      .with(headers: { "Authorization" => "token some_token" })
      .to_return(
        body: body,
        headers: { "Content-Type" => "application/json" },
      )
  end
end
