Version: 1.1.0 | Date: 2026-09-30

# Anthropic 官方來源：撰寫「模型讀的指令檔」的規則彙整

## 範圍與讀法

本文只收「模型會讀的常駐指令文字」的撰寫規則，
也就是 always-loaded 的規則檔（CLAUDE.md / 系統提示）與 SKILL.md / agent 定義。
人類對 Claude 下聊天提示的技巧、互動式提示教學、給應用程式用的 Console 提示產生器，一律不收。
每條 takeaway 都寫成「在規則檔 / SKILL.md 裡該怎麼改」。

來源限定 Anthropic 官方網域與 `github.com/anthropics/*`，全部於 2026-09-30 以 WebFetch 實際抓取。
抓取品質分兩種，標在每個來源的第一行：

- 【全文】：工具回傳頁面原文，引文可信。
- 【摘要】：工具只回傳小模型摘要，引文出自摘要、未對原頁逐字核對，使用前請回原頁確認。

若網址被 302 / 308 轉址，條目列出「實際抓取的網址」，並註明轉址來源。
找不到或未抓到的東西，一律寫 `not found` 或 `[unconfirmed]`，沒有用記憶補洞。

---

## 1. 撰寫系統提示 / 常駐指令的文字

### 1.1 Prompting best practices

- 標題：Prompting best practices（頁面自稱網址為 `.../claude-prompting-best-practices`）
- 網址：https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-4-best-practices
  （由 `docs.claude.com/.../claude-4-best-practices` 302 轉來）
- 【全文】
- 在規則檔裡：
  - 補「為什麼」，不要只下禁令。原文範例：把 `NEVER use ellipses` 改成說明「回應會被文字轉語音讀出，所以不要用刪節號」，
    理由是 "Claude is smart enough to generalize from the explanation."
  - 收斂強硬語氣。原文：
    "The fix is to dial back any aggressive language. Where you might have said "CRITICAL: You MUST use this tool when...",
    you can use more normal prompting like "Use this tool when..."."
    這句針對 Opus 4.5 / 4.6，但同頁 migration 第 6 點對整個 4.6 世代都說 "dial back that guidance"。
  - 拿掉「保險式」的觸發句。原文："Instructions like "If in doubt, use [tool]" will cause overtriggering."，
    並建議 "Replace blanket defaults with more targeted instructions."
  - 用正向敘述。原文："Tell Claude what to do instead of what not to do"（例：不要寫「不要用 markdown」，改寫「回應由流暢的散文段落組成」）。
  - 頁面對「某型號專屬的技巧」有一條通用保險：要 "treat it as measured on that model and re-check it against your own evals before applying it to another."
  - 結構用 XML 標籤把指令、脈絡、範例分開（"reduces misinterpretation"），範例建議 3–5 個並包在 `<example>` 內。
- 頁內可直接抄進規則檔的段落：Balancing autonomy and safety（不可逆 / 影響共享系統的動作先問，
  並寫 "do not use destructive actions as a shortcut"）、Overeagerness（"Avoid over-engineering.
  Only make changes that are directly requested or clearly necessary."）。
- Applies to: 兩者（全域 CLAUDE.md 與 SKILL.md 的措辭層面）

### 1.2 Prompting Claude Sonnet 5.5（適用型號：Claude Sonnet 5.5）

- 標題：Prompting Claude Sonnet 5.5
- 網址：https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5-5
- 【全文】
- 在規則檔裡：
  - 「做到哪、何時停」用兩句話就能定：
    `Keep working until everything the user asked for is done,
    and only stop to ask when you can't go on without the user or before a risky step.` 加上 `When the work the user asked for is done and checked,
    stop and report. Don't add features, tests, files, docs or refactors that weren't asked for.`
  - 官方明說這段不取代你自己的風險規則："The prompt doesn't replace your own rules about risky or irreversible actions. Keep those rules in your system prompt."
  - 若發現「沒跑測試就回報完成」，加一段驗證規則：要求 "run a real check that exercises the change before reporting it done"，
    且 "A syntax-only check, or a check command that failed to start, does not count"，跑不了時要 "say which one you did not run and why"。
  - 刪掉會壓抑必要工具使用的句子，例如 "only use tools when strictly necessary" 或 "minimize tool calls"。
  - 使用者只是要點子 / 方案時，一句話擋住擅自動手：`When the user asks for ideas, options or a plan, give them that and stop.`
  - 高 effort 下不想讓模型自行叫 reviewer subagent，可加：
    `don't launch reviewer sub-agents unless the user asked for a review.` 官方測試 "cut session cost by about a third, with no change in quality"。
- Applies to: 全域 CLAUDE.md（範圍 / 完成 / 驗證 / 委派段落）

### 1.3 Prompting Claude Fable 5（適用型號：Claude Fable 5 / Mythos 5；較新的 Fable 5.1 見 1.6）

- 標題：Prompting Claude Fable 5
- 網址：https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5
- 【全文】
- 在規則檔 / SKILL.md 裡：
  - 舊 skill 要瘦身。原文：
    "Skills developed for prior models are often too prescriptive for Claude Fable 5 and can degrade output quality.
    Review and consider removing older instructions if default performance is better."
  - 不必逐條列舉行為，一句概括即可："you can steer most behaviors with a brief instruction rather than enumerating each behavior by name."
  - 把「何時可以停下來問人」寫成一條通則，而非窮舉：
    `Pause for the user only when the work genuinely requires them: a destructive or irreversible action, a real scope change,
    or input that only they can provide.`
  - 要模型回報進度時，要求逐項對照本回合工具結果："audit each claim against a tool result from this session"；
    官方測試 "nearly eliminated fabricated status reports"。
  - 附上意圖：`Give the reason, not only the request`（原文小節標題），說明為何要這樣做，長任務尤其有效。
  - 不要在規則檔要求模型「把內部推理寫進回覆」。原文：
    "Prompts, skills, or harness instructions that tell the model to echo, transcribe,
    or explain its internal reasoning as response text can trigger the `reasoning_extraction` refusal category"。
  - 驗證建議："Separate, fresh-context verifier subagents tend to outperform self-critique."（與 1.4 的說法方向不同，見下一條）
- Applies to: 兩者

### 1.4 Prompting Claude Opus 5（適用型號：Claude Opus 5；較新的 Opus 5.5 見 1.5）

- 標題：Prompting Claude Opus 5
- 網址：https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5
- 【全文】
- 在規則檔裡：
  - 明文驗證指令可能過頭。原文：
    "If your prompt contains explicit verification instructions ("include a final verification step for any non-trivial task," "use a subagent to verify"),
    remove them: instructions like these cause over-verification on Claude Opus 5"。
  - 委派範例句可直接套用：
    "Delegate to a subagent only for large tasks that are genuinely independent and parallelizable...
    do not use subagents to verify or double-check your own work."
  - 審查類指令別寫「只報嚴重問題」。原文：
    "If your review prompt says "only report high-severity issues" or "be conservative," the model may follow that instruction literally and report less;
    ask it to report everything and filter in a separate pass instead."
  - 要控制語氣 / 格式，給「想要的風格範例」比列禁令有效：
    "Positive examples of the communication style you want tend to be more effective than instructions about what not to do."
  - 不要要求「再檢查一次 / double-check」這類模型本來就會做的動作，官方說會 "add cost without improving results"。
  - 產出文件的長度要單獨校準："Match the length of written documents to what the task needs"。
- 注意：1.3 與 1.4 對「驗證要不要寫進指令、要不要用 subagent 驗證」的建議因型號而異，不是矛盾，是兩個型號各自量測的結果。
  這兩頁都不是「目前」型號的頁面；Opus 5.5 與 Fable 5.1 的頁面（1.5、1.6）明說舊頁的做法仍可當起點，並未取代，也沒有重述驗證 / 驗證用 subagent 的措辭，
  所以這組差異仍然存在。規則檔若跨型號使用，需自行用 eval 決定（見第 5 節）。
- Applies to: 全域 CLAUDE.md（委派與完成定義段落）

### 1.5 Prompting Claude Opus 5.5

- 標題：Prompting Claude Opus 5.5
- 網址：https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5
- 適用型號：Claude Opus 5.5
- 【全文，逐字抽取】
- 在規則檔裡：
  - 舊頁沒有被取代："Existing Claude Opus 5 prompts should perform well without changes,
    and the patterns in Prompting Claude Opus 5 remain a reasonable starting point."
    → 1.4 的驗證 / 委派 / 範圍 / 長度條文仍是 Opus 5.5 的起點。
  - 驗證、自我檢查、subagent 委派、強調詞、長度：本頁沒有這幾類的獨立段落（not found），不要把「本頁沒提」讀成「規則已改」。
  - 拿掉要求模型「把推理寫進回覆」的句子：
    "a prompt that pushes the model to reproduce its reasoning in the response text can be declined with the `reasoning_extraction` refusal category."
  - 拿掉「先仔細想想再回答」這類思考指令："consider removing them for Claude Opus 5.5. The model decides for itself how much to think"，
    要少想就降 effort："Lowering effort reduces thinking ... more reliably than prompt instructions do."
  - 用「點名具體的提前停手類型」取代籠統的「要完整做完」：
    "Claude Opus 5.5 is responsive to instructions that name the specific kinds of early stop you want it to avoid"，也要點名你要它停的情況。
    官方範例段落結尾保留 "This does not override the need for confirmation on risky or destructive actions."，並警告該段
    "leave the addition out of human-in-the-loop applications, where someone is there to answer."
    → 這類「全自動不要停」的句子不適合原樣放進需要人工把關的全域規則檔。
  - 要更新頻率就直接寫：「say so in the system prompt; the model is responsive to such instructions」（例：開工前一句話說明要做什麼、結尾一段短回顧）。
  - 否定句要「點名」才有效：頁面在前端設計段說，泛稱的 "avoid a generic AI look" 只會 "swaps one default for another"，
    "It responds well to instructions that name specific patterns to avoid"。
  - 工作前先廣泛探索的一句話：`Before taking any action, explore broadly with tool calls: list and open the ...
    that could be relevant to this task, including ones the task does not explicitly mention, and use what you find.`
    官方提醒因為它會照找到的東西行動，"keep untrusted content out of the records it searches."
- Applies to: 全域 CLAUDE.md（Opus 5.5 專用措辭）

### 1.6 Prompting Claude Fable 5.1

- 標題：Prompting Claude Fable 5.1
- 網址：https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-1
- 適用型號：Claude Fable 5.1 / Mythos 5.1
- 【全文】
- 在規則檔 / SKILL.md 裡：
  - 舊頁沒有被取代："Your existing Claude Fable 5 prompts should perform well on Claude Fable 5.1 without changes"。
    驗證用 subagent 的措辭、強調詞的專屬段落：本頁沒有（not found）；subagent 只有一段 harness 建議，
    "don't force the lead agent to stop and wait for each one"，屬於 harness 設計，不是規則檔措辭。
  - 反格式化規則要改成「什麼時候用格式」：
    "Earlier models overused bullets and bold in chat, and many prompts carry anti-formatting rules written to hold that down.
    Claude Fable 5.1 leans the other way ... If your prompt contains anti-formatting language,
    remove it or replace it with a rule that says when specific formatting is appropriate"。
  - 先刪壓制敘述的句子，再談加：
    "audit your prompt for instructions that suppress narration ...
    such as "hold all findings for the final response." Remove lines like that before adding anything."
    要更新就寫「什麼時候要、每則要含什麼」：開工前一行說明、結尾 "a short recap that stands on its own"。
    [推論] 規則檔若含「不要前言、不要回顧」一類的通則，需確認不會讓長任務的中途更新與最終回顧一起消失。
  - 範圍控制用一段完整範例句："Keep changes to what the request needs" 與
    "don't fix, optimize or extend it in this change unless the requested behavior cannot work without it; report it as a follow-up in your summary."
    官方數據："unrequested additions and committed test code drop substantially with no measurable change in task success."
    段內還有 "Verify your work however you like; scratch scripts and quick checks need not be kept."，即驗證方式交給模型，只規範要不要留下測試檔。
  - 「做完再停」段的兩段式提示，第一段要整段照用，尤其開頭那句告知使用者不在場："The opening sentence,
    which tells the model the user isn't watching, carries much of the effect. Keep it as written."
    官方註明代價："This block can also make the model less likely to ask about ambiguous requests"，
    且原文把「回報 'continue'」定位為適合 "pair programming and other human-in-the-loop work"。
    → 這也是不適合直接放進需要「階段完成後停下等指示」的全域規則檔的段落。
  - 描述反模式時要「定義它」而不是列禁令：對密集的文風，官方給的是一段定義 mannered prose 的文字（含對照例句），
    "An instruction that defines the anti-pattern ... helps"，短版 "Please remove all mannered prose." 也常有效。
  - 需要特定行為時附一個完整範例（請求、 回應、 為何正確的一句話） ，而非再加規則：
    "add one complete example of a correct response to the system prompt: the user's request, the response,
    and a sentence explaining why the response is correct."
  - 需要摘要保留要點時列出必留項目（本頁給了六項：遇到的困難與處理、 已試 / 擱置的方案與原因、
    被要求 / 決定 / 排除的事項並「stated exactly」、 目前進度、 未決事項、 難以重建的細節） ，
    可當交接類 SKILL.md 的檢查表。
- Applies to: 兩者（全域 CLAUDE.md 的格式 / 範圍 / 完成段落；交接類 SKILL.md）

---

## 2. CLAUDE.md / 記憶

### 2.1 How Claude remembers your project（Claude Code memory）

- 標題：How Claude remembers your project
- 網址：https://code.claude.com/docs/en/memory
- 【全文】
- 在規則檔裡：
  - 長度上限：官方建議 "target under 200 lines per CLAUDE.md file. Longer files consume more context and reduce adherence."
  - `@import` 不省 context："Imports help you organize a long file but don't reduce its context cost, because imported files also load at launch."
    要真的省，得改成 path-scoped rules（`paths` frontmatter）或 skill。無 `paths` 的 `.claude/rules/*.md` 一樣在啟動時載入。
  - 寫成可驗證的句子。原文對照："Use 2-space indentation" instead of "Format code properly"。
  - 矛盾會被任意擇一："if two instructions contradict each other, Claude may pick one arbitrarily."
    使用者層與專案層規則衝突時同樣 "Claude may follow either one, so keep the two consistent."
  - CLAUDE.md 是脈絡不是強制：
    "Claude treats them as context, not enforced configuration. To block an action regardless of what Claude decides, use a PreToolUse hook instead."
    它以 user message 形式送入，不是系統提示本體（"delivered as a user message after the system prompt"）。
  - 多步驟程序或只關乎部分程式碼的內容，搬到 skill 或 path-scoped rule。
  - 給維護者看的註解用區塊級 HTML 註解 `<!-- ... -->`，注入前會被剝掉，不花 token（程式碼區塊內的註解會保留）。
  - 稽核入口：`/doctor prompt-audit`（詳見 5.1）。
- Applies to: 全域 CLAUDE.md

### 2.2 Best practices for Claude Code

- 標題：Best practices for Claude Code
- 網址：https://code.claude.com/docs/en/best-practices
  （由 `anthropic.com/engineering/claude-code-best-practices` 308 轉來）
- 【全文】
- 在規則檔裡：
  - 逐行自問：
    "Would removing this cause Claude to make mistakes?" If not, cut it. 原文並警告 "Bloated CLAUDE.md files cause Claude to ignore your actual instructions!"
  - 該收 / 不該收有對照表。不收：Claude 讀程式碼就能知道的事、語言通用慣例、"Self-evident practices like "write clean code""、逐檔說明。收：
    猜不到的指令、和預設不同的風格、環境怪癖、"Common gotchas or non-obvious behaviors"。
  - 強調詞只給一行：
    "If Claude keeps skipping one instruction, add emphasis such as "IMPORTANT" to that line alone. If you emphasize many lines, none of them stands out."
  - 規則要當程式碼維護：
    "Treat CLAUDE.md like code: review it when things go wrong, prune it regularly, and test changes by observing whether Claude's behavior actually shifts."
  - 失敗模式 "The over-specified CLAUDE.md" 的解法："If Claude already does something correctly without the instruction, delete it or convert it to a hook."
  - 「每次都要發生」的事用 hook："Unlike CLAUDE.md instructions which are advisory, hooks are deterministic and guarantee the action happens."
  - 寫給審查者的委派提示只交 diff 與判準，不交推理（"sees only the diff and the criteria you give it, not the reasoning that produced the change"），
    並限縮判定範圍："Tell the reviewer to flag only gaps that affect correctness or the stated requirements"，否則會導致過度工程。
- Applies to: 全域 CLAUDE.md

### 2.3 Extend Claude Code（features overview）

- 標題：Extend Claude Code
- 網址：https://code.claude.com/docs/en/features-overview
- 【全文】
- 在規則檔裡：
  - 判斷放哪裡：CLAUDE.md 放「Claude 每次都該知道」的事；偶爾才需要的參考資料或工作流放 skill；一定要發生的放 hook。
  - 護欄放 hook：
    "An instruction like "never edit .env" in CLAUDE.md or a skill is a request, not a guarantee. A `PreToolUse` hook that blocks the edit is enforcement."
  - 重申 "Rule of thumb: Keep CLAUDE.md under 200 lines. If it's growing, move reference content to skills or split into `.claude/rules/` files."
  - 成本表：CLAUDE.md 與 output style 每次請求都付全額；skill 只有 description 每次付；hook 除非回傳內容否則為零。
  - 多層 CLAUDE.md 是疊加、衝突時 "Claude uses judgment to reconcile them"，所以全域與專案兩層不要重複同一條。
- Applies to: 全域 CLAUDE.md

### 2.4 Steering Claude Code: when to use CLAUDE.md, skills, hooks, and subagents（官方部落格）

- 標題：Steering Claude Code: when to use CLAUDE.md, skills, hooks, and subagents
- 網址：https://claude.com/blog/steering-claude-code-skills-hooks-rules-subagents-and-more
- 【摘要】（以下引文出自摘要，未逐字核對）
- 在規則檔裡：
  - "Don't put automation in CLAUDE.md"：「每次 X 就做 Y」改用 hook。
  - "Don't use instructions for hard guardrails"：「never do this」在壓力下會失守，硬性阻擋用 hook（exit code 2）。
  - "Don't hide 30-line procedures in CLAUDE.md"：長程序搬去 skill。
- 與 2.3 重疊，只作為交叉佐證。
- Applies to: 全域 CLAUDE.md

---

## 3. Agent Skills 撰寫

### 3.1 Skill authoring best practices

- 標題：Skill authoring best practices
- 網址：https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
  （由 `docs.claude.com/.../best-practices` 302 轉來）
- 【全文】
- 在 SKILL.md 裡：
  - 只寫模型還不知道的東西。原文自問三句：
    "Does Claude really need this explanation?" / "Can I assume Claude knows this?" / "Does this paragraph justify its token cost?"
  - description 用第三人稱，且同時寫「做什麼」與「何時用」，含具體觸發詞。原文 "Always write in third person"；官方反例：
    "Helps with documents"、"Processes data"。上限 1,024 字元、不可含 XML 標籤。
  - 自由度配合風險：脆弱、必須照順序的操作給精確指令（"Do not modify the command or add additional flags."）；多解法的判斷任務給方向即可。
  - 本文 "Keep SKILL.md body under 500 lines"；超過就拆檔，且 "Keep references one level deep from SKILL.md"；超過 100 行的參考檔開頭放目錄。
  - 給預設、留逃生口，不要列一堆選項（"Avoid offering too many options"）。
  - 術語一致（"Choose one term and use it throughout the Skill"）；避免會過期的時間句，改放 "old patterns" 區。
  - 複雜流程用可勾選清單；品質關鍵處寫 validate → fix → repeat 迴圈。
  - 先寫 eval 再寫文件："Create evaluations BEFORE writing extensive documentation."；
    清單要求 "At least three evaluations created" 與 "Tested with Haiku, Sonnet, and Opus"。
  - 官方 Claude A / Claude B 流程：一個實例協助寫、另一個全新實例實測，依觀察改，不憑假設。
  - 內文有一句提醒改寫時可考慮 "stronger language such as "MUST filter" instead of "always filter""，與 3.6 的「講理由、少用 MUST」取向不同，
    兩者並存，實際以 eval 結果決定。
- Applies to: SKILL.md

### 3.2 Agent Skills overview

- 標題：Agent Skills
- 網址：https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview
- 【全文】
- 在 SKILL.md 裡：
  - 三層載入：metadata 約 100 tokens / skill（常駐）、SKILL.md 本文 "Under 5k tokens"（觸發後載入）、其餘資源用到才讀。
    所以「何時觸發」的資訊必須全部塞進 description，本文才不會被看到。
  - 原文："The `description` is what Claude matches your request against ... so it must say both what the Skill does and when to use it."
  - 腳本是執行而非閱讀：只有輸出進 context，程式碼不進；決定性操作寫成腳本並在 SKILL.md 明說「執行」還是「參考」。
  - 安全：skill 只裝可信來源，會抓外部 URL 的 skill 風險特別高，"Even trustworthy Skills can be compromised if their external dependencies change over time"。
  - 自製 skill 不會跨 surface 同步（Claude Code、claude.ai、API 各自獨立），本 repo 用 `npx skills` 分發時要記得每台機器各自更新。
- Applies to: SKILL.md

### 3.3 Extend Claude with skills（Claude Code skills）

- 標題：Extend Claude with skills
- 網址：https://code.claude.com/docs/en/skills
- 【全文】
- 在 SKILL.md 裡：
  - description 前置關鍵用途：`description` 與 `when_to_use` 合計在 skill 清單中被截在 1,536 字元（"Put the key use case first"）。
  - 清單總預算約為 context 的 1%，超出時 "Claude Code drops descriptions starting with the skills you invoke least"，等於關鍵詞被拿掉、觸發變差；
    用 `/doctor` 看估計成本，用 `/skill-doctor` 找可關的 skill。
  - "Keep `SKILL.md` under 500 lines. Move detailed reference material to separate files."
  - 有副作用的工作流加 `disable-model-invocation: true`，只允許手動 `/name` 觸發。
  - 壓縮後每個被叫用過的 skill 只重新附上前 5,000 tokens，
    且所有 skill 共用 25,000 tokens 預算（"older skills can be dropped entirely after compaction"），所以關鍵規則放 SKILL.md 前段。
  - 欄位名稱拼錯不會報錯，只是被忽略："Claude Code ignores a field it doesn't recognize without reporting an error."；
    YAML 壞掉時 skill 本文照載入但 metadata 為空，Claude 無法比對 description。
    可用 `claude plugin validate <skills 目錄>` 檢查（需 v2.1.233+）。
  - 觸發不準的排查：description 要含使用者自然會說的關鍵詞；太常誤觸則把 description 寫具體。
  - 評估方式（同頁「Evaluate and iterate on a skill」）見 5.2。
- Applies to: SKILL.md

### 3.4 Equipping agents for the real world with Agent Skills

- 標題：Equipping agents for the real world with Agent Skills
- 網址：https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills
  （工具回報實際頁面位於 anthropic.com/news/skills，未另行抓取）
- 【摘要】（以下引文出自摘要，未逐字核對）
- 在 SKILL.md 裡：
  - "Pay special attention to the `name` and `description` of your skill. Claude will use these when deciding whether to trigger the skill."
  - 本文變大時 "split its content into separate files and reference them"；互斥或少用的脈絡分開放可省 token。
  - "Iterate with Claude"：做事時請 Claude 把成功做法與常見錯誤整理成 skill 的內容。
- 與 3.1、3.2 重疊，只作為交叉佐證。
- Applies to: SKILL.md

### 3.5 anthropics/skills（官方 skills 倉庫）

- 標題：GitHub - anthropics/skills
- 網址：https://github.com/anthropics/skills 與 https://github.com/anthropics/skills/tree/main/skills
- 【摘要】
- 在 SKILL.md 裡：
  - README 的最小範本只有 `name` 與 `description` 兩個必填欄位，description 是 "A complete description of what the skill does and when to use it"。
  - 一致性檢查：README 摘要說「沒有名為 skill-creator 的 skill」，
    但 `skills/` 目錄清單摘要列出 `skill-creator`（另有 `claude-api`、`doc-coauthoring`、`mcp-builder` 等）；以目錄清單為準，
    README 摘要那句視為不可靠。
- Applies to: SKILL.md（僅作範本參考）

### 3.6 skill-creator 的 SKILL.md（官方 skill 的寫法本身）

- 標題：skill-creator SKILL.md
- 網址：https://raw.githubusercontent.com/anthropics/skills/main/skills/skill-creator/SKILL.md
- 【全文，逐字抽取】（第一次抓取只拿到摘要，第二次以逐字抽取提示取得下列原句）
- 在 SKILL.md 裡：
  - 講理由，別靠大寫命令。原文："Try hard to explain the **why** behind everything you're asking the model to do."
    並且："If you find yourself writing ALWAYS or NEVER in all caps, or using super rigid structures, that's a yellow flag"，
    建議 "reframe and explain the reasoning so that the model understands why the thing you're asking for is important."
  - description 要 "a little bit 'pushy'" 以對抗觸發不足，範例是在功能描述後加上
    "Make sure to use this skill whenever the user mentions dashboards, data visualization, internal metrics, ...,
    even if they don't explicitly ask for a 'dashboard.'"
  - 頑固問題不要靠加碼："Rather than put in fiddly overfitty changes, or oppressively constrictive MUSTs, ...
    you might try branching out and using different metaphors, or recommending different patterns of working."
  - 本文 "Keep SKILL.md under 500 lines; if you're approaching this limit,
    add an additional layer of hierarchy along with clear pointers about where the model using the skill should go next"。
  - 讀 transcript 而不只讀最終輸出，砍掉讓模型做白工的段落：
    "you can try getting rid of the parts of the skill that are making it do that and seeing what happens."
  - 另（第一次摘要，未在逐字抽取中出現）提到多個測試 run 各自重寫相似輔助腳本時應收進 `scripts/`：`[unconfirmed]`。
- Applies to: SKILL.md

---

## 4. 子代理 / 委派 / 脈絡工程

### 4.1 Create custom subagents

- 標題：Create custom subagents
- 網址：https://code.claude.com/docs/en/sub-agents
- 【全文，逐字抽取】（第一次抓取只拿到摘要，第二次以逐字抽取提示取得下列原句）
- 在規則檔 / agent 定義裡：
  - 非 fork subagent 會載入完整 CLAUDE.md 階層，原文：
    "every level of the CLAUDE.md hierarchy the main conversation loads, including `~/.claude/CLAUDE.md`, project rules, `CLAUDE.local.md`,
    managed policy files, and any `AGENTS.md` files loaded as project instructions. The built-in Explore and Plan agents skip this."
    代表全域規則檔的每個字，每個 subagent 都再付一次成本。
  - 自訂 agent 可用 `omitClaudeMd`（需 v2.1.271+）：
    "Set to `true` to launch this subagent without the user, project, and local CLAUDE.md files; managed policy files still load ...
    Use it for subagents that take everything they need from the delegation prompt."
    → 委派提示自足的唯讀輔助 agent 可評估開啟。
  - description 決定何時委派："Claude uses each subagent's description to decide when to delegate tasks."
    想促成主動委派，"include phrases like 'use proactively' in your subagent's description field."
  - 所有自訂 subagent 的 description 合計超過 15,000 tokens 會在啟動時警告
    （"exceed 15,000 tokens, Claude Code shows a warning at startup"）。
  - subagent 收不到主對話的格式與記憶：
    "a subagent runs its own system prompt, so your output style doesn't shape its responses, except in a fork."
    "Auto memory: the main conversation's auto memory isn't loaded."
    → 要它遵守的格式必須寫進委派提示或 agent 本文。
  - 何時用 subagent、模型解析順序（呼叫參數、agent frontmatter、`CLAUDE_CODE_SUBAGENT_MODEL`、主對話模型）出自第一次抓取的摘要，未逐字核對。
- Applies to: 兩者（全域 CLAUDE.md 的委派段 + agent 定義檔）

### 4.2 Effective context engineering for AI agents

- 標題：Effective context engineering for AI agents
- 網址：https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- 【摘要，但下列引文來自「逐字抽取」的第二次抓取】
- 在規則檔裡：
  - 找對「高度」。原文：
    "The right altitude is the Goldilocks zone between two common failure modes." 一端是 "hardcoding complex, brittle logic in their prompts"，
    另一端是 "vague, high-level guidance that fails to give the LLM concrete signals for desired outputs or falsely assumes shared context."
  - 只留必要資訊："you should be striving for the minimal set of information that fully outlines your expected behavior."
  - 用少量多樣的代表性範例取代窮舉邊角案例："curate a set of diverse, canonical examples ... examples are the 'pictures' worth a thousand words."
  - context 是有限資源：
    "as the number of tokens in the context window increases,
    the model's ability to accurately recall information from that context decreases." → 常駐規則檔越長，
    每條規則被記住的機率越低。
  - 即時載入：
    "maintain lightweight identifiers (file paths, stored queries, web links, etc.)
    and use these references to dynamically load data into context at runtime" → 規則檔放「路由表 + 檔案路徑」，
    內容用到才讀。
  - 第一次抓取的摘要另提到「先用最小提示在最強模型上測，再依失敗模式逐步加指令」，此句未在逐字抽取中出現，標為 `[unconfirmed]`。
- Applies to: 全域 CLAUDE.md

### 4.3 Building effective agents

- 標題：Building Effective AI Agents
- 網址：https://www.anthropic.com/engineering/building-effective-agents
- 【摘要】（以下引文出自摘要，未逐字核對）
- 在規則檔裡：
  - "Success in the LLM space isn't about building the most sophisticated system.
    It's about building the right system for your needs." → 規則檔先從最簡單的版本起，
    失敗了才加條文。
  - evaluator-optimizer 適用於 "clear evaluation criteria exist"：要求審查者做迭代修正前，先把可檢查的判準寫清楚。
  - 工具（ACI）文件要下和人機介面同等的功夫：含用法範例、邊界情況（"Poka-yoke" 防呆），對應到 SKILL.md 裡呼叫腳本 / 指令的段落。
- Applies to: 兩者

### 4.4 How we built our multi-agent research system

- 標題：How we built our multi-agent research system
- 網址：https://www.anthropic.com/engineering/multi-agent-research-system
  （工具回報頁面實際位於 `anthropic.com/research/how-we-built-our-multi-agent-research-system`）
- 【摘要，但下列引文來自「逐字抽取」的第二次抓取】
- 在規則檔裡（尤其是委派模板）：
  - 委派提示必備四要素：
    "Each subagent needs an objective, an output format, guidance on the tools and sources to use, and clear task boundaries."（第一次抓取另指出，
    指令太籠統會造成 subagent 重複工作與遺漏。）
  - 把「依難度調整投入」寫進規則：
    "Simple fact-finding requires just 1 agent with 3-10 tool calls, direct comparisons might need 2-4 subagents with 10-15 calls each,
    and complex research might use more than 10 subagents."
  - 讓模型幫你改提示："When given a prompt and a failure mode, they are able to diagnose why the agent is failing and suggest improvements."
  - "Agent-tool interfaces are as critical as human-computer interfaces."
  - 先廣後窄的搜尋指令："prompting agents to start with short, broad queries."
- Applies to: 全域 CLAUDE.md（§ 委派提示的固定格式）

### 4.5 Writing effective tools for AI agents

- 標題：Writing effective tools for AI agents
- 網址：https://www.anthropic.com/engineering/writing-tools-for-agents
  （工具回報的實際網址為 `.../writing-effective-tools-for-agents-with-agents`）
- 【摘要，但下列引文來自「逐字抽取」的第二次抓取】
- 在 SKILL.md（含其呼叫的腳本 / 工具說明）裡：
  - "prompt-engineering your tool descriptions and specs" 是改善工具效果最有效的方法之一 → SKILL.md 裡描述腳本用途、參數的句子要當提示來寫。
  - "Tool implementations should take care to return only high signal information back to agents." → 腳本輸出精簡、可讀。
  - "More tools don't always lead to better outcomes." → 一個 skill 不要暴露過多入口。
  - 命名分組："grouping related tools under common prefixes"；第一次抓取另提到錯誤訊息要能引導（"actionable"），標為 【摘要】。
- Applies to: SKILL.md

---

## 5. 稽核 / 改善 / 評估「模型讀的指令檔」的內建工具

### 5.1 `/doctor prompt-audit` 與 `/claude-api prompt-audit`（官方有文件）

- 標題：How Claude remembers your project（章節 "Audit your instruction files"）
- 網址：https://code.claude.com/docs/en/memory
  另見 https://code.claude.com/docs/en/commands（`/doctor` 條目）與 https://code.claude.com/docs/en/skills（章節 "Work on Claude API projects" 的子指令表）
- 【全文】
- 在規則檔 / SKILL.md 上實際怎麼用：
  - 指令：`/doctor prompt-audit`；也可指定路徑，例如 `/doctor prompt-audit .claude/skills/deploy`。需 Claude Code v2.1.283 以上。
  - 檢查什麼：原文 "instructions written for older models, references to files or commands that don't exist, and files that contradict each other."
  - 預設涵蓋：CLAUDE.md、CLAUDE.local.md、AGENTS.md，加上 `.claude/` 與 `~/.claude/` 底下的 rules、skills、commands、subagents、output styles。
  - 產出：附建議修改的問題報告，"nothing in your files changes until you ask Claude to apply them."
  - 底層是內建 `/claude-api` skill 的 `prompt-audit` 子指令：
    skills 頁的表格說明為 "Flag instructions written for older models in your prompts, skills,
    and tool descriptions and propose fixes as a diff"（需 v2.1.221+）。
    若 `skillOverrides` 或 `disableBundledSkills` 關掉該 skill，稽核就不可用。
  - `/doctor`（不帶參數）另有「CLAUDE.md 瘦身檢查」：砍掉 Claude 能從程式碼推得的內容（目錄結構、依賴清單、架構總覽），
    保留 pitfalls、rationale 與偏離預設的慣例，並把常駐指引遷移成 skill 與巢狀 CLAUDE.md。文件明確寫的對象是 checked-in 的 CLAUDE.md，
    是否涵蓋 `~/.claude/CLAUDE.md`：`[unconfirmed]`。需 v2.1.206+。
- Applies to: 兩者

### 5.2 Skill 評估：baseline 對照、skill-creator plugin、`claude plugin eval`、`/skill-doctor`

- 標題：Extend Claude with skills（章節 "Evaluate and iterate on a skill"）
- 網址：https://code.claude.com/docs/en/skills （同 3.3）
  另見 https://code.claude.com/docs/en/plugin-evals、
   https://claude.com/blog/improving-skill-creator-test-measure-and-refine-agent-skills、
   https://github.com/anthropics/claude-plugins-official/tree/main/plugins/skill-creator
- 【skills 頁、plugin-evals 頁：全文；skill-creator 部落格與 GitHub 目錄：摘要】
- 在 SKILL.md 上實際怎麼用：
  - 觀念："Seeing a skill trigger tells you Claude found it, not that it did what you intended." 要分開量「有沒有被叫用」與「輸出對不對」。
  - 做法：選幾個貼近真實的 prompt，各在全新 session 跑兩次（有 skill / 用 `skillOverrides` 設 `"off"`），比較結果。原文強調 fresh session，
    因為撰寫過程殘留的脈絡會掩蓋指令寫得不足的地方。
  - skill-creator plugin：`/plugin install skill-creator@claude-plugins-official`，會把測試案例存成 skill 目錄內的 `evals/evals.json`，
    每案一個 subagent 隔離執行、產生 `grading.json` 與 `benchmark.json`（with-skill vs without-skill 的通過率 / 時間 / tokens）、
    支援兩版 skill 的盲測 A/B、以及 description 調校（產生 should-trigger / should-not-trigger 的 prompt 量命中率） 。
  - 部落格的觀察（摘要）：測試顯示 description 調校改善了 6 個公開文件類 skill 中的 5 個；並區分「能力提升型」與「編碼偏好型」skill，
    兩者隨模型演進需要不同的測法。
  - `claude plugin eval`（需 v2.1.269+）是給打包成 plugin 的 skill：每案預設跑三次、並同時跑「無 plugin」baseline，輸出 `WITH` / `W/OUT` / `Δ`；
    文件建議常見第一個發現是 "a `Δ` near zero with the case's `tool_used: Skill` grader failing"，意思是 Claude 沒有在自然措辭下選中你的 skill，
    解法是改 description。可設門檻讓 CI 失敗。每次 eval 都是真實模型呼叫、會計費。
  - 兩套 eval 檔案格式互不通用（`evals/evals.json` 與 `claude plugin eval` 的 case 目錄）。
  - `/skill-doctor`（需 v2.1.252+）：顯示每個 skill 的 context 成本與使用頻率，找出可關閉的。
  - 純本機 repo 的 skill 若不打包成 plugin，`claude plugin eval` 是否可直接用：`[unconfirmed]`（文件前提是有 `plugin.json` 或 skills-directory plugin）。
- Applies to: SKILL.md

### 5.3 建立 / 檢視指令檔：`/init`、`/memory`、`/context`

- 標題：Commands
- 網址：https://code.claude.com/docs/en/commands
- 【全文】
- 在規則檔上實際怎麼用：
  - `/init`：產生起始 CLAUDE.md；已存在時是建議改善而非覆寫（memory 頁）。設 `CLAUDE_CODE_NEW_INIT=1` 會改成互動流程，一併規劃 skills 與 hooks。
  - `/memory`：編輯各層 CLAUDE.md，並看哪些檔案有被載入。
  - `/context`：確認某份 CLAUDE.md 或 rules 是否真的載入（"check the list under Memory files"），排查「規則沒生效」的第一步。
  - memory 頁另指出可用 `InstructionsLoaded` hook 記錄哪些指令檔在何時、為何載入，除錯 path-scoped rules 很有用。
  - 內建 `/code-review`、`/simplify`、`/security-review` 是審查程式碼用，不審查指令檔本身，與本文範圍無關，僅在此註明。
- Applies to: 全域 CLAUDE.md

### 5.4 `/claude-api` skill 說明頁（查 prompt-audit 是否有公開說明）

- 標題：Claude API skill
- 網址：https://platform.claude.com/docs/en/agents-and-tools/agent-skills/claude-api-skill
- 【全文】
- 結論：這一頁沒有描述 `prompt-audit`（頁面只詳述 `migrate` 與 `managed-agents-onboard`），`prompt-audit` 的官方說明在 5.1 的 Claude Code 文件頁。
- 唯一與指令檔有關的一句在 `migrate` 的「Prompt-behavior tuning」：
  會 "flagging length-control, tool-triggering, subagent, and instruction-following prompts that may behave differently on the target model"。
  可當作審視自己規則檔的四類清單：長度控制、工具觸發、subagent、遵循指令的措辭。
- Applies to: 兩者（僅作檢查清單）

### 5.5 Hooks 作為強制層

- 標題：Automate actions with hooks
- 網址：https://code.claude.com/docs/en/hooks-guide
- 【全文】
- 在規則檔上實際怎麼用：
  - 從規則檔遷出「必須發生」的條文："certain actions always happen rather than relying on the LLM to choose to run them."
  - `PreToolUse` 回傳 `permissionDecision` 為 `deny` 會取消工具呼叫並把 `permissionDecisionReason` 回饋給 Claude；exit 2 也是阻擋；
    同事件多個 hook 時採最嚴格者（順序 deny、defer、ask、allow）。
  - 需要判斷而非固定規則時可用 `type: "prompt"` 或 `type: "agent"` hook（agent hook 標為 experimental）。
  - `PreToolUse` hook 在任何 permission mode 之前觸發，"A hook that returns `permissionDecision: "deny"` blocks the tool even in `bypassPermissions` mode"。
  - Stop hook 可擋住回合結束直到檢查通過，但連續阻擋 8 次無進展會被覆寫；腳本要檢查 `stop_hook_active`。
  - 文件警告 hook 對 Bash 子指令的過濾是 best-effort，硬性允許 / 拒絕應改用 permission 系統。
- Applies to: 全域 CLAUDE.md

### 5.6 Output styles（模型讀的格式指令）

- 標題：Output styles
- 網址：https://code.claude.com/docs/en/output-styles
- 【全文】
- 在規則檔上實際怎麼用：
  - 回應格式 / 語氣這類「整個 session 都要」的指令，
    官方建議用 output style 而不是塞進 CLAUDE.md（"An output style gives Claude instructions to follow.
    It doesn't guarantee that something always happens or never happens."）。
  - 自訂 style 是含 frontmatter 的 Markdown，放 `~/.claude/output-styles`；`keep-coding-instructions: true` 才保留內建的軟體工程指令。
  - 僅作用於主對話與 fork，其他 subagent 用自己的系統提示，不吃 output style。
  - 內建 Concise 風格的行為描述可當措辭參考："the first sentence of a response states what happened or what the answer is"。
- Applies to: 全域 CLAUDE.md

---

## 未找到 / 未確認 / 已排除

- `/claude-api prompt-audit` 的公開說明：在 Claude Code 文件找到（memory、commands、skills 三頁）；在 `claude-api-skill` 說明頁 not found（見 5.4）。
- `/skill-doctor`、`claude plugin eval`：找到（見 5.2）。獨立的 "skill-doctor" 專頁 not found，說明只在 skills 與 commands 頁。
- 對「純本機、未打包 plugin」的 skill 是否可直接用 `claude plugin eval`：`[unconfirmed]`。
- `/doctor` 的 CLAUDE.md 瘦身檢查是否涵蓋 `~/.claude/CLAUDE.md`：`[unconfirmed]`。
- 4.2 中「先最小提示再逐步加指令」一句：`[unconfirmed]`（僅見於第一次摘要）。
- Opus 5.5 頁與 Fable 5.1 頁：驗證 / 自我檢查指令、驗證用 subagent 的措辭、強調詞（大寫、MUST）的獨立說明，皆 not found；兩頁都只說舊型號頁的模式仍可沿用。
  Opus 5.5 頁對回應長度也 not found。
- 依 llms.txt 尚有 Prompting Claude Sonnet 5 與 Opus 4.8 頁，未抓取（使用者目前型號為 Opus 5.5 / Sonnet 5.5 / Fable 5.1，
  Sonnet 5.5 頁已在 1.2） ：`[unconfirmed]`。
- Console 的 prompt improver / prompt generator 對應的平台文件頁（`.../prompt-improver`、`.../prompt-generator`、`.../prompting-tools`）：
  抓取時三個網址都回傳 "Prompting best practices" 頁的內容，頁內沒有相關段落，視為 not found。另抓過 `claude.com/blog/prompt-improver`（2024-10-14），
  內容是給 API 應用程式提示用，依範圍規則排除。`anthropic.com/news/prompt-generator` 只出現在搜尋結果，未抓取，`[unconfirmed]`。
- 依範圍規則排除（已抓過但無規則檔撰寫 takeaway）：
  `github.com/anthropics/prompt-eng-interactive-tutorial`（給使用者的教學）、`github.com/anthropics/courses`（教學，
  README 標示 2026-09-15 已封存）、`github.com/anthropics/claude-cookbooks`（範例集）、`code.claude.com/docs/en/goal`（是 session 中設定完成條件的指令，
  不是撰寫指令檔的規則）、`github.com/anthropics/claude-code`（README 摘要無 CLAUDE.md 撰寫指引；另抓其 `CLAUDE.md` 原始檔，回傳摘要自承路徑不確定，
  不採用）。

---

## Top 5 actionable changes

排序依據：對「常駐規則檔越短越好、必須發生的事交給機制」這條主軸的槓桿大小，其次是可用官方工具量測。
本機對照數字為 2026-09-30 以 `wc` 實測（唯讀）：全域 CLAUDE.md 234 行 / 26,840 bytes；
本 repo 各 SKILL.md 為 completion-gate 247 行、git-helper 184、handover 108、haos-addon-deploy 396、haos-cloud-backup 225、
haos-https-tunnel 124、python-coding-standards 149、web-stack-selector 147。

1. 把全域 CLAUDE.md 壓到 200 行以下，程序性長段改成「按需讀取」。
   - 做法：逐行套用「刪掉會不會讓 Claude 犯錯」；
     把 wrap-up 順序、委派門檻細則、skill 路由這類多步驟程序搬到 skill 或只在需要時才讀的檔案（現有 §10 路由表的「用到才讀」做法與官方 just-in-time 一致，
     可再擴大）。注意 `@import` 與無 `paths` 的 rules 都不省 context。
   - 依據：
     https://code.claude.com/docs/en/memory （"target under 200 lines"、imports 不省 context）、
     https://code.claude.com/docs/en/best-practices （"Would removing this cause Claude to make mistakes?"）、
     https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents （"minimal set of information"、context 遞減報酬）。
   - 佐證成本：非 fork 的 subagent 也載入這份檔（https://code.claude.com/docs/en/sub-agents，【全文，逐字抽取】），縮短同時降低每次委派的成本；
     唯讀輔助 agent 可評估 `omitClaudeMd: true`，前提是委派提示已自足。

2. 把「必須發生」的條文改成 hook，CLAUDE.md 只留需要判斷的規則。
   - 做法：例如「commit 前先問 git-helper」這類固定閘門，用 `PreToolUse` hook 對 `git commit` 回 `ask`；
     「改檔後必須驗證」這類收尾閘門評估用 Stop hook（prompt 或 agent 型）。規則檔對應條文就可以刪掉或縮成一行理由。既有的危險指令 hook 已是這個模式，
     往同方向補齊。
   - 依據：
     https://code.claude.com/docs/en/features-overview （"a request,
     not a guarantee"）、https://code.claude.com/docs/en/hooks-guide、https://code.claude.com/docs/en/best-practices （"convert it to a hook"）。
   - 風險：hook 對 Bash 子指令的比對是 best-effort，Stop hook 連續阻擋 8 次會被覆寫，所以只適合當第二道，不取代 §3 的判斷條文。

3. 用 `/doctor prompt-audit` 稽核整份 `~/.claude`（規則、skills、agents、output styles），再人工套三條措辭規則。
   - 做法：先跑稽核拿 diff（需 v2.1.283+）；再手動檢查：
     強調詞只留在真正的 P0 一兩行、否定句改成「該做什麼 + 為什麼」、刪掉為舊模型寫的「加強型」句子（"If in doubt, use [tool]"、"double-check" 之類）。
     本機 `grep` 實測：大寫強調詞（NEVER / MUST / IMPORTANT / CRITICAL） 0 行、 「non-negotiable」1 行、 粗體 `**` 6 行、
     含 never / don't / do not / no 的行 42 行，
     所以重點不在大寫，而在否定句改寫、舊模型遺留句，以及粗體與「non-negotiable」式標記是否稀釋了真正的 P0。
   - 附帶檢查 [推論，非官方明文]：規則要求模型「附上理由 / reasoning」時，若指的是對使用者的決策說明（依據、證據）就沒問題；
     若可能被解讀成「回述內部推理」，官方指出會觸發 `reasoning_extraction`，建議措辭改成「列出依據與證據」。
   - 依據：
     https://code.claude.com/docs/en/memory （prompt-audit）、
     https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-4-best-practices （dial back、
     "Tell Claude what to do instead of what not to do"）、https://code.claude.com/docs/en/best-practices （"emphasis ...
     to that line alone"）、
     https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5 （reasoning_extraction、
     skills 過度規定） 。

4. 驗證與委派條文依「目前使用的型號」實測，並把審查者範圍限縮句寫進委派模板。
   - 適用範圍先講清楚（已對照 Opus 5.5 與 Fable 5.1 兩頁）：這兩頁都明說舊型號頁的做法仍可當起點，沒有取代，
     但也都沒有重述驗證或「用 subagent 驗證」的措辭（Opus 5.5 頁與 Fable 5.1 頁各為 not found）。
     所以 Opus 5 頁與 Fable 5 頁的建議繼續適用於各自的後繼型號，衝突沒有消失：
     - Opus 5 / 5.5 線：明文驗證指令會造成 over-verification，且 "do not use subagents to verify or double-check your own work"。
     - Fable 5 / 5.1 線：Fable 5 頁建議獨立 fresh-context verifier 勝過自我批判；Fable 5.1 頁只說 "Verify your work however you like"，沒有反對也沒有加強。
     - Sonnet 5.5：低 effort 常漏跑檢查，建議加驗證段；xhigh 時反而要擋自行啟動的 reviewer。
   - 做法：不要直接刪或直接加，先用第 5 點的方法在實際使用的型號上量測，再決定 §4 / §5 各列是否依型號分級。
     新增且與型號無關的兩件低風險事：
     (a) 在 §4.1 的委派模板加 "Report gaps, not style preferences" 與 "flag only gaps that affect correctness or the stated requirements"，
     並保留「委派提示包含目標、判準與回報格式，不含推理」（與 Claude Code 官方文件一致）。
     (b) 檢查規則檔有沒有「先仔細想想」「回述推理」一類句子並刪除（Opus 5.5 頁、Fable 5 頁皆指出可能觸發 `reasoning_extraction`）。
     同時不要把 Opus 5.5 / Fable 5.1 頁的「全自動不要停」提示原樣搬進全域規則檔，兩頁都註明那是給無人在場的情境，會降低詢問頻率。
   - 依據：
     https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5、
     https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-1、
     https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5、
     https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5、
     https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5-5、
     https://code.claude.com/docs/en/best-practices、https://www.anthropic.com/engineering/multi-agent-research-system 。

5. 替每個 SKILL.md 建立「有 / 無 skill」的 baseline 評估，並把 description 與長度調到官方門檻內。
   - 做法：先對最像「編碼偏好型」的 completion-gate 與 git-helper 各做 3 個以上貼近真實的 prompt，在 fresh session 比較有 / 無 skill；
     工具用 skill-creator plugin（含 description 調校與盲測 A/B）。description 檢查四點：
     第三人稱、同時寫做什麼與何時用、關鍵用途放最前面（合計 1,536 字元上限）、含使用者自然會說的詞。另跑 `/skill-doctor` 看 context 成本，
     跑 `claude plugin validate` 抓 frontmatter 拼錯（未知欄位會被靜默忽略）。SKILL.md 的關鍵規則放前段，
     因為壓縮後每個 skill 只重新附上前 5,000 tokens。各 SKILL.md 行數目前都在 500 行內，但 completion-gate 的 token 數是否逼近 5,000：
     `[unconfirmed]`，未實測。
   - 依據：
     https://code.claude.com/docs/en/skills （Evaluate and iterate、1,536 字元、500 行、compaction 預算）、
     https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices （"Create evaluations BEFORE writing extensive documentation"、
     第三人稱、Haiku / Sonnet / Opus 皆測）、
     https://claude.com/blog/improving-skill-creator-test-measure-and-refine-agent-skills 【摘要】。
