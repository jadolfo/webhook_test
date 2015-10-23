
Skip to content
titletitle log in | sign up
 
Jenkins
All
GitHubTrigger
configuration
 Back to Dashboard
 Status
 Changes
 Workspace
 Build with Parameters
 Delete Project
 Configure
 GitHub
 Job Config History
collapsetrend0%Build History
Failed > Console Output#5 Oct 14, 2015 7:13 PM 
Failed > Console Output#4 Oct 14, 2015 7:13 PM 
Failed > Console Output#3 Oct 14, 2015 7:12 PM 
Failed > Console Output#2 Oct 14, 2015 7:12 PM 
Failed > Console Output#1 Oct 14, 2015 7:12 PM 
Feed RSS for all Feed RSS for failures
 	Project name		
 	Description	
[Escaped HTML] Preview 	
Discard Old Builds	Help for feature: Discard Old Builds
 	GitHub project		Help for feature: GitHub project
This build is parameterized	Help for feature: This build is parameterized
Text Parameter
 	Name		Help for feature: Name
 	Default Value	
Help for feature: Default Value
 	Description	
[Escaped HTML] Preview 	Help for feature: Description
Delete
Add Parameter
Prepare an environment for the run	Help for feature: Prepare an environment for the run
Disable Build (No new builds will be executed until the project is re-enabled.)	Help for feature: Disable Build (No new builds will be executed until the project is re-enabled.)
Execute concurrent builds if necessary	Help for feature: Execute concurrent builds if necessary
Restrict where this project can be run	Help for feature: Restrict where this project can be run
 	Label Expression		
Slaves in label: 1
Advanced Project Options
 
Advanced...
Source Code Management
 None	
 CVS	
 CVS Projectset	
 Git	
 	Repositories	
 	Repository URL		Help for feature: Repository URL
 	Credentials	
 
 Add
 
Advanced...
 		
Add Repository
Delete Repository
Help for feature: Repositories
 	Branches to build	
 	Branch Specifier (blank for 'any')		Help for feature: Branch Specifier (blank for 'any')
 		
Add Branch
Delete Branch
 	Repository browser		Help for feature: Repository browser
 	Additional Behaviours	
Add
 Subversion	
Build Triggers
Trigger builds remotely (e.g., from scripts)	Help for feature: Trigger builds remotely (e.g., from scripts)
 	Authentication Token	Use the following URL to trigger build remotely: JENKINS_URL/view/All/job/GitHubTrigger/build?token=TOKEN_NAME or /buildWithParameters?token=TOKEN_NAME
Optionally append &cause=Cause+Text to provide text that will be included in the recorded build cause.	
Build after other projects are built	Help for feature: Build after other projects are built
Build periodically	Help for feature: Build periodically
Build when a change is pushed to GitHub	
GitHub Pull Request Builder	
Poll SCM	Help for feature: Poll SCM
Build Environment
Delete workspace before build starts	
Inject environment variables to the build process	Help for feature: Inject environment variables to the build process
Inject passwords to the build as environment variables	
Keychains and Code Signing Identities	
Mobile Provisioning Profiles	
Restore OS X keychains after build process as defined in global configuration	
SSH Agent	
Build
Execute system Groovy script
[Help]
 		
 Groovy command	
 		

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
67
68
69
70
71
72
73
74
75
76
77
78
79
80
81
82
83
84
85
86
87
88
89
90
91
92
93
94
95
96
97
98
99
100
101
102
103
104
105
106
107
108
109
110
111
112
113
114
115
116
117
118
119
120
121
122
123
124
125
126
127
128
129
130
131
132
133
134
135
136
137
138
139
140
141
142
143
144
145
146
147
148
149
150
151
152
153
154
155
156
157
import groovy.json.JsonSlurper
import hudson.model.*
  
class Payload
{
  def _build = Thread.currentThread()?.executable
  def _json
 
  def pullID
  def branch
  def head
  def buildVersion
  def buildNotes  
  
  /* -------------------------------------
    This only returns "true" if:
    - payload is a 'pull_request' event     
    - action field == 'closed'
    - branch follows "release-*" pattern
  ----------------------------------------*/
  def isValid()
  {
    // get json payload from the build parameter
    def resolver = _build.buildVariableResolver
    def payload = resolver.resolve("payload")
  
    def js = new JsonSlurper()
    _json = js.parseText(payload)
    
    // check event type, associated action, and branch
    if (_json.keySet().contains('pull_request'))
    {
      if (_json.keySet().contains('action'))
      {
        if (_json.action.equals('closed'))
        {
          // grab the branch name
          branch = _json.pull_request.base.ref
          return (branch.toLowerCase().contains('release-'))
        }
      }
    }
 
    return false
  }  
  
  def releaseSummary()
  {
    StringBuilder sb = new StringBuilder()
    sb.append('version: ' + p.buildVersion + ' [Build ' + buildNumber + ']')
    sb.append('\t comments: \r\n')
    sb.append('\t - ' + _json.pull_request.title)
    sb.append()
    
  }
  
  def process()
  {
    // grab pull request ID        
    pullID = _json.number
            
    // grab pull-origin
    head = _json.pull_request.head.ref
    
    // grab version from branch name
    buildVersion = branch.tokenize('-')[1]
    
    // compile release summary
    releaseSummary()
  }
}
 
def buildNumber = this.binding.build.project.builds[0].toString().tokenize('#')[1]
def p = new Payload()
if (p.isValid())
{
  println('\r\n')
  println('Triggering builds on branch: ' + p.branch)
  
  p.process() 
  println('Pull ID: ' + p.pullID)
  println('Pull origin: ' + p.head)
  println('Version: ' + p.buildVersion + ' [Build ' + buildNumber + ']')
  println('\r\n')
  
  println('-- Release Summary --')
  
}
 
 
 
/* globals
def _branch
def _pullRequest
def _build = Thread.currentThread()?.executable
 
//pulls/908/commits?"
  
Boolean processPayload()
{
    
  return false;
}
 
def getCommits(pullID)
{
  def url = "https://api.github.com/repos/costcomobility/Costco-iOS" 
  def token = "?access_token=911debf855a43cff867aeab27ebd10f8c3068b94"
  
  StringBuilder sb = new StringBuilder()
  sb.append(url)
    .append('/pulls/' + pullID + '/commits')
    .append(token)
  
  // println(sb.toString())
  
  def js = new JsonSlurper()
  def json = js.parseText(['/bin/bash', '-c', 'curl -s ' + sb.toString()].execute().text)
  
  json.commit.each { commit ->
    println(commit.message)
  }
  
  return
}
def releaseSummary()
{
  StringBuilder sb = new StringBuilder()
  sb.append('Release Notes:')
    .append('\r\n')
    .append('Version: ' + _branch.tokenize('-')[1]
    .append('\r\n')
    .append('Build: ' + this.binding.build.project.builds[0].toString().tokenize('#')[1])
    .append('\r\n')
    .append(getCommits())        
  
  return sb.toString()
}
 
def triggerBuild()
{
  processPayload()
  if (_branch.toLowerCase().contains("release-"))
  {
    println("Triggering builds on branch: " + branch)
    def pa = new ParametersAction([
      new StringParameterValue("Branch", branch),
      new StringParameterValue("BuildConfiguration","debug"),
      new StringParameterValue("ReleaseNotes", releaseSummary()),
    ])
    
    _build.addAction(pa)        
  }
}
 
triggerBuild()
*/
 		
Check syntax
 Groovy script file	
 
Advanced...
Delete
Add build step
Post-build Actions
Add post-build action
Save
Apply
 Help us localize this page Page generated: Oct 15, 2015 3:16:50 PMREST APIJenkins ver. 1.609.2
