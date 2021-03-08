#!/usr/bin/env python3

import datetime, json, os, sys
from urllib.request import Request, urlopen

sys.path.append(os.path.join(os.path.dirname(__file__), '../py'))
from swiftbar.utils import ft_print

# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideLastUpdated>true</swiftbar.hideLastUpdated>
# <swiftbar.hideDisablePlugin>true</swiftbar.hideDisablePlugin>
# <swiftbar.hideSwiftBar>true</swiftbar.hideSwiftBar>

# Personal access token with full repo permissions
with open(
    os.path.join(os.path.dirname(__file__),
                 '.github-review-requests.json')) as f:
  data = json.load(f)
  ACCESS_TOKEN = data['ACCESS_TOKEN']
  GITHUB_LOGIN = data['GITHUB_LOGIN']

DARK_MODE = os.environ.get('BitBarDarkMode')

QUERY = '''{
  search(query: "%(query)s", type: ISSUE, first: 100) {
    issueCount
    edges {
      node {
        ... on PullRequest {
          repository {
            nameWithOwner
          }
          author {
            login
          }
          createdAt
          mergeable
          number
          url
          title
          commits(last: 1) {
            nodes {
              commit {
                statusCheckRollup {
                  state
                }
              }
            }
          }
          labels(first:100) {
            nodes {
              name
            }
          }
        }
      }
    }
  }
}'''


def ft_search(login: str):
  search_query = f'type:pr state:open review-requested:{login}'
  response = ft_query(QUERY % {'query': search_query})
  return response['data']['search']


def ft_query(query: str):
  headers = {
    'Authorization': 'bearer ' + ACCESS_TOKEN,
    'Content-Type': 'application/json',
  }
  data = json.dumps({'query': query}).encode('utf-8')
  req = Request('https://api.github.com/graphql', data=data, headers=headers)
  body = urlopen(req).read()
  return json.loads(body)


def parse_date(text: str):
  date_obj = datetime.datetime.strptime(text, '%Y-%m-%dT%H:%M:%SZ')
  return date_obj.strftime('%B %d, %Y')


if __name__ == '__main__':
  if not all([ACCESS_TOKEN, GITHUB_LOGIN]):
    ft_print('⚠ Github review requests', color='red')
    ft_print('---')
    ft_print('ACCESS_TOKEN and GITHUB_LOGIN cannot be empty')
    sys.exit(0)

  response = ft_search(GITHUB_LOGIN)

  ft_print(f':arrow.triangle.pull: #{response["issueCount"]}')
  ft_print('---')

  CI_STATE = {
    None: (':questionmark: ', 'default'),
    'EXPECTED': (':questionmark: ', 'default'),
    'ERROR': (':xmark:', 'crimson'),
    'FAILURE': (':xmark:', 'crimson'),
    'PENDING': (':arrow.triangle.2.circlepath:', 'mediumspringgreen'),
    'SUCCESS': (':checkmark:', 'mediumspringgreen')
  }

  for pr in [r['node'] for r in response['edges']]:

    title = '%s - %s' % (pr['repository']['nameWithOwner'], pr['title'])
    ci_status = (pr['commits']['nodes'][0].get('commit', {}).get(
      'statusCheckRollup', {}) or {}).get('state', None)
    subtitle = '%s #%s opened on %s by @%s | sfcolor=%s' % (
      CI_STATE[ci_status][0], pr['number'], parse_date(
        pr['createdAt']), pr['author']['login'], CI_STATE[ci_status][1])

    labels = [l['name'] for l in pr['labels']['nodes']]

    ft_print(title, href=pr['url'], size=13)
    if labels:
      ft_print('-- Labels', color='black', size=13)
      for label in labels:
        ft_print(f'-- {label}')
    ft_print(subtitle, color='lightgrey')
    ft_print('---')

  ft_print(
    'Refresh | href="swiftbar://refreshplugin?name=github-review-requests" terminal=false'
  )
