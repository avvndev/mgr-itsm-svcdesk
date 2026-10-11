Laboratory instructions

Every command runs in the root of your repository. On Linux and macOS use ./itsmlab.sh; on Windows PowerShell use .\itsmlab.ps1, and ; where the examples chain commands with &&. Every laboratory follows the same ten steps: steps 0 to 3 are specific to the laboratory, and steps 4 to 9 are identical in every laboratory, only the number changes. One order matters in this laboratory: the assistant's first draft is committed before you measure and design your own ladder. Nothing receipts that order, but both verdicts score the same, so there is nothing to gain from rewriting the draft after the measurement.

The 150 minutes
#	Core item	min	by minute	step
1	kb-index in your compose file, GET /kb/search (M-01, M-02)	15	15	1 and 3
2	The histogram with route templates, /metrics, the cardinality rule (M-03 to M-07)	20	35	3
3	Ask the assistant for a ladder and an alert rule, commit its answer; load 3; both verdicts in ai-first-draft.md (M-25 to M-27)	20	55	2 and 3
4	Design your ladder, measure again (M-11 to M-13)	10	65	3
5	slo.md (M-14 to M-16)	10	75	3
6	alerts.yml and alerts_test.yml, until no mutant survives and the probes pass (M-17 to M-21)	25	100	3
7	The dashboard (M-22 to M-24), verify 3, commit, tag, take the submission receipt	10	110	3 to 8
The Core items take 110 minutes; the remaining 40 are slack. If an item overruns by more than its budget, stop, run the checker, and ask on the forum with the check id. Item 6 is the one that overruns.

Step 0. Check your setup
docker pull ghcr.io/swasik/itsmlab:2026
./itsmlab.sh --version # Linux, macOS
.\itsmlab.ps1 --version # Windows PowerShell
The second command prints the checker version; this laboratory needs itsmlab 0.8.0 or newer, the image published on 7 October 2026, the first on the :2026 tag that knows Laboratory 3, and the version the grader runs since that day. An image pulled before 7 October prints itsmlab 0.3.2: it does not know Laboratory 3 at all, and does not carry the instruments it needs (its own Prometheus, promtool, oha and Toxiproxy). Your repository does not change; the checker image is the only thing you update. Then pull the images of the laboratory; these tags replace the planned list in the pre-work:

docker pull ghcr.io/swasik/seeded-toxic:2026
docker pull prom/prometheus:v3.15.0
docker pull grafana/grafana:13.2.3
In itsmlab.yaml, set lab: 3. repository: must hold your real <your GitHub login>/<your repository> before your first submit; the template's placeholder is refused with a message. Your login: the checker derives your kb-index profile from login: in itsmlab.yaml when it is there, else from the owner part of repository:; load 3 and verify 3 print the login they used, and stop with a message when neither is set. The grader uses the login of your receipt, the GitHub account that opens the submission issue. If your repository's owner is not your own login (an organisation, a second account), add login: <your login>: with the wrong login you measure somebody else's profile, while the grader measures yours and judges your ladder, your verdict and your evidence against it. Nothing in Laboratory 3 reads baselines:; leave it and the other keys as they are.

Step 1. Add kb-index and the package's files to your repository
Download Laboratory 3 package (the Download folder button gives one ZIP) and copy into the root of your repository:

from the package	into your repository
prometheus/ (all three files)	prometheus/
grafana/ (the whole tree)	grafana/
the services of compose-lab3.yml, and KB_INDEX_URL	your docker-compose.yml, merged by hand
slo-template.md	slo.md
ai-first-draft-template.md	ai-first-draft.md
Stretch only: gap-template.json, genai/DIFF-template.md, k8s/values.yaml	gap.json, genai/DIFF.md, k8s/values.yaml
compose-lab3.yml is not a compose file of its own: copy its three services into the services: of your docker-compose.yml, next to your svcdesk. kb-index runs ghcr.io/swasik/seeded-toxic:2026 with SEEDED_TOXIC_LOGIN set to your own GitHub login (left empty, the container stops at once and says so); your own prometheus and grafana run under the observability profile. Add KB_INDEX_URL: http://kb-index:8080 to the environment of svcdesk. Give kb-index no healthcheck: the image has no shell, so a check that runs a command inside it can never pass, and docker compose up --wait then fails L3-CORE-1.04. buckets-flawed.example.yml is for reading and need not be in your repository: the checker carries its own copy.

docker compose up -d --build svcdesk kb-index # the two services the checker starts
docker compose --profile observability up -d # plus your own Prometheus (:9090) and Grafana (:3000)
Step 2. Ask the assistant first, and commit its answer
Before your first measurement and before you design anything, ask an assistant for histogram bucket boundaries and an alert rule for GET /kb/search. Paste your prompt under ## Prompt and its whole answer under ## Answer in ai-first-draft.md, verbatim, and copy its ladder into the front matter, in seconds, exactly as it gave it. If the answer itself contains lines that begin with ## , put > in front of every line of it: the checker reads a section up to the next line that begins with ## . The minute budget puts this at item 3, after the histogram, and that is fine: until item 4, instrument with the library's default buckets or with the assistant's ladder. The verdicts come in step 3, after the measurement.

No AI at all: set source: instructor, delete tool, copy the fourteen boundaries of buckets-flawed.example.yml into ladder, and delete ## Prompt and ## Answer. Every path reaches the same grade bands.

git add ai-first-draft.md
git commit -m "Lab 3 first draft"
git push origin main
Step 3. Implement, measure, and run the checker as often as you like
What you work from: MONITORING-SPEC.md defines the endpoint, the histogram, the measurement and every rule behind the SLO, the alerts and the dashboard; HANDOUT.md, section "The dependency: kb-index", gives the whole interface of kb-index; the check identifiers the table prints back at you are listed in CHECKS.md.

The endpoint and the histogram. For each valid GET /kb/search?q=<text> (q of 1 to 200 characters) svcdesk makes exactly one call to kb-index, with no cache, no retry and a timeout of at least 2 s, and answers 200 with the upstream's hits unchanged; any other q gets 400 or 422, and a failure upstream gets 502 with the error code upstream_unavailable. A q that begins with force-error always gets kb-index's 503: that is how you test your 502 path. One histogram, http_server_request_duration_seconds, in seconds, observes every request exactly once, with exactly the labels http_request_method, http_route (the route template, never a raw path or a query string) and http_response_status_code. Answer /metrics with a Content-Type of text/plain: the checker's own Prometheus 3.15.0 refuses to scrape anything else.

The measurement. The one that decides your grade (M-08) is open-loop: after a 5-second warm-up, 40 requests per second for 60 seconds over 64 connections, each latency measured from the instant the request was scheduled. Run it with the checker:

./itsmlab.sh load 3 # Linux, macOS
.\itsmlab.ps1 load 3 # Windows PowerShell
./itsmlab.sh load 3 --ladder 0.1,0.2,0.21,0.22,0.25 # Linux, macOS: also judge a ladder you are considering
.\itsmlab.ps1 load 3 --ladder "0.1,0.2,0.21,0.22,0.25" # Windows PowerShell: quote the ladder
load 3 builds and starts svcdesk and kb-index exactly as verify 3 does, with your login's profile and the admin endpoints off, and prints the login it used, the percentiles, q, q_kb, the status codes, oha's own latency histogram, whether your service's ladder, the flawed ladder and your --ladder resolve q (M-11), and your histogram's own p99 over the run (M-12). The measurement takes about 100 seconds after the build and the start. The published practice profile (--login practice) is for trying things out; the checker and the grader never use it for you.

The design. With the p99 that load 3 printed, write both evidence blocks and both verdicts in ai-first-draft.md. Then design your own ladder, at most 30 boundaries, for a band of at least ±10 % around your q (see Laboratory description), make your latency SLI's threshold one of its boundaries (M-13), and measure again.

The verify loop.

./itsmlab.sh verify 3 # Linux, macOS
.\itsmlab.ps1 verify 3 # Windows PowerShell
./itsmlab.sh verify 3 --json report.json # Linux, macOS
.\itsmlab.ps1 verify 3 --json report.json # Windows PowerShell
Local runs are unlimited and never count as attempts. The exit code is 0 when every Core specification passes, 1 when at least one does not, and 2 when the checker itself could not run. The table prints one row per specification, with status pass, fail, error or skip; Core passes when no Core specification is fail or error. verify 3 takes two to three minutes after the build, because it repeats the measurement every time. A request that only prepares a check is not a check: when one fails, every check that depends on it is reported as error with the reason.

The alerts, the item that overruns. While you write the tests, run promtool locally, a second per run:

docker run --rm -v "$PWD/prometheus:/p" -w /p --entrypoint promtool prom/prometheus:v3.15.0 check rules alerts.yml # Linux, macOS
docker run --rm -v "$PWD/prometheus:/p" -w /p --entrypoint promtool prom/prometheus:v3.15.0 test rules alerts_test.yml # Linux, macOS
docker run --rm -v "${PWD}/prometheus:/p" -w /p --entrypoint promtool prom/prometheus:v3.15.0 check rules alerts.yml # Windows PowerShell
docker run --rm -v "${PWD}/prometheus:/p" -w /p --entrypoint promtool prom/prometheus:v3.15.0 test rules alerts_test.yml # Windows PowerShell
When they pass, run verify 3: L3-CORE-5.04 lists every mutant that survived, and 5.05 to 5.07 print the instants they asserted and what they found. The one worked alert in the template's prometheus/alerts.yml is a single-window rule that the checker's reset probe fails on purpose: it shows the file formats and the two test edges that kill mutants, and it goes when your own alerts arrive.

What you produce in this step, besides the code:

ai-first-draft.md - both evidence blocks with the p99 you measured, the bucket [lo, hi] that holds it and its relative width; the draft's verdict, confirmed if its ladder resolves your p99 and refuted if it does not; the flawed ladder's verdict, always refuted; and the arithmetic in prose (M-25 to M-27).
slo.md - start from slo-template.md: a window from 7d to 90d, two SLIs (availability and latency) whose good and valid queries each return one sample, objectives in [0.9, 1), the error budget as a fraction and in minutes, a latency threshold that is one of your boundaries, and at least two alerts on the same SLI with different burn rates; then the defence in prose. Write le as Prometheus 3 stores it: le="0.3", le="1.0".
prometheus/alerts.yml and prometheus/alerts_test.yml - exactly one alerting rule per declared alert, with the labels service: svcdesk, slo and severity (P1, P2 or P3; at least one declared alert is P1), every threshold a constant in the rule's own expr, and tests that kill every mutant.
grafana/dashboards/*.json - at least three panels with queries, one of them a histogram_quantile over http_server_request_duration_seconds_bucket, and no library panels. Export the JSON from your own Grafana without the option that prepares it for another Grafana instance.
For Stretch, two of: genai/spans.json with genai/DIFF.md, gap.json with gap/README.md, and the four k8s/ files. HANDOUT.md, section "Stretch", gives the package versions that work together and the Toxiproxy commands.
When a check fails, the usual causes:

check	the usual cause
1.02	a bind mount (./x:/y) on svcdesk or kb-index; your prometheus and grafana may have them
1.04	a healthcheck on kb-index: it has no shell, so the check can never pass
2.05	a label too many: an OpenTelemetry Prometheus exporter adds labels of its own (such as otel_scope_name)
2.07, 2.09	the raw path (/tickets/<an id>) or the query string in http_route, instead of the template
2.08, 3.06	milliseconds instead of seconds
3.02, 3.03	a cache, a retry, or an answer that does not wait for kb-index
3.04	a request observed twice (a middleware and a decorator), or not at all
3.05	the grader's q next to your one fine bucket: resolve a band
3.07, 3.08	evidence from a different run or profile than the checker's, or a verdict the measurement contradicts
4.04, 6.03 and 6.04 error ("could not scrape svcdesk's /metrics") while CORE-2 passes	/metrics answered without a text/plain Content-Type: Prometheus 3 refuses to scrape it (M-03)
5.04	tests that assert only when the alert fires: add that it is not yet firing one evaluation earlier
5.05 to 5.07	a threshold that is not the declared burn rate, a missing route filter, a missing short window
6.04	a metric name no one exposes, or a panel on ALERTS
Step 4. Commit and push the implementation
git status
git add -A
git commit -m "Lab 3 attempt 1"
git push origin main
Step 5. Verify the committed tree, and go through the checklist
Run ./itsmlab.sh verify 3 (Windows: .\itsmlab.ps1 verify 3) once more and check two things: it exits 0, and its commit line does not say (dirty). (dirty) means your working directory holds changes that are not in the commit, so the grader would evaluate different files from the ones you just tested. Then go through the checklist; if anything on it is missing, fix it and return to step 4.

./itsmlab.sh verify 3 (Windows: .\itsmlab.ps1 verify 3) exits 0: every Core specification pass;
itsmlab.yaml says lab: 3, names your repository, and carries login: when the repository's owner is not you; verify 3 printed your own login;
kb-index runs ghcr.io/swasik/seeded-toxic:2026 with SEEDED_TOXIC_LOGIN set to your login and no healthcheck, svcdesk has KB_INDEX_URL, and neither has a bind mount;
your ladder resolves a band of at least ±10 % around your q, and the latency threshold in slo.md is one of its boundaries;
ai-first-draft.md holds the exchange verbatim (or source: instructor), both verdicts with their arithmetic, and a p99 measured with load 3;
slo.md carries the defence in prose, not the template's instructions;
your promtool tests pass and no mutant survives;
the dashboard JSON is committed under grafana/dashboards/;
every checked file, slo.md, ai-first-draft.md and prometheus/*.yml included, carries the ai-generated: header;
the repository is public;
the implementation is committed and pushed, git status is clean, and verify 3 did not say (dirty);
for Stretch, two of: the GenAI diff, the latency gap, the Kubernetes track.
Step 6. Tag that commit and push the tag
git tag -a lab3/v1 -m "Lab 3 attempt 1"
git push origin lab3/v1
-a creates an annotated tag, which is the form the receipt workflow resolves. Use lab3/v1 for the first attempt, lab3/v2 for the second and lab3/v3 for the third. A tag never moves: if you change anything after the receipt, do not move the tag, go back to step 4 and use the next tag name. A tag that moved after its receipt voids that attempt, and the attempt still counts.

Step 7. Take the submission receipt
./itsmlab.sh submit 3 --kind submission --tag lab3/v1 # Linux, macOS
.\itsmlab.ps1 submit 3 --kind submission --tag lab3/v1 # Windows PowerShell
It prints a warning: when the working tree has uncommitted changes or when HEAD has moved past the tag, and it prints the commit and the tree_sha it will claim. Open the printed URL while logged in to GitHub as the login on the roster, which must be the login whose profile you measured: the grader measures the profile of the account that opens the issue. Check the fields, and click Submit new issue. Within about a minute the course bot comments with your receipt and labels the issue receipted. If it refuses instead (the repository is not on the roster, the tag was not found, this would be a fourth attempt), fix the cause and open a new issue: a refused issue is not an attempt.

Step 8. Record the submission in Moodle
Paste into the Laboratory 3 assignment below, as online text: the URL of the submission issue and the tag you submitted. For a later attempt, edit the same submission and paste the newest issue URL and tag. This step is required: the grade comes from the receipt, never from the text you paste there, but that entry is where your mark is recorded, and Laboratory 3 is not complete without it.

Step 9. Read your grade, and decide on another attempt
The grade arrives as a comment itsmlab grade on the submission issue, usually within twenty minutes, with grade.json and its Sigstore bundle. If nothing appears within an hour, ask on the forum with the issue number. How to check that the signature is genuine is on the How grading works, technically page in the General section. To improve the result, fix the cause and go back to step 4 with the next tag; the best of the three attempts counts.