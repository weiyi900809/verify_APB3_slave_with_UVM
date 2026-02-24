# APB3 UVM VIP

學習 SystemVerilog、APB3 協議與 UVM 驗證方法論的實作專案。

## 專案目標

開發一個完整的 APB3 UVM Verification IP，包含：
- APB3 Master Agent - 驅動 APB3 匯流排
- APB3 Slave Agent - 模擬 APB3 周邊
- 完整的驗證環境與測試案例

## 目錄結構

```
apb3-uvm-vip/
├── README.md
├── book/                        # 參考書籍
│   ├── SystemVerilog for Verification(最新版).pdf
│   └── UVM实战 卷Ⅰ.pdf
├── .claude/skills/              # Claude Code Skills (AI 輔助)
│   ├── apb3/                    # APB3 協議知識
│   ├── uvm/                     # UVM 元件指南
│   ├── sv/                      # SystemVerilog 語法
│   └── gen/                     # 程式碼生成器
├── rtl/                         # RTL 設計 (TODO)
├── tb/                          # UVM Testbench (TODO)
└── sim/                         # Simulation scripts (TODO)
```

## Claude Code Skills

本專案使用 Claude Code Skills 輔助開發，提供即時的協議知識與程式碼模板。

### 可用指令

| 指令 | 用途 |
|------|------|
| `/apb3-signals` | APB3 訊號定義與方向 |
| `/apb3-fsm` | APB3 三態狀態機設計 |
| `/apb3-timing` | APB3 時序圖與時序要求 |
| `/apb3-assertions` | APB3 協議斷言 (SVA) |
| `/uvm-transaction` | UVM Sequence Item 撰寫 |
| `/uvm-driver` | UVM Driver 撰寫 |
| `/uvm-monitor` | UVM Monitor 撰寫 |
| `/uvm-agent` | UVM Agent 撰寫 |
| `/uvm-env` | UVM Environment 撰寫 |
| `/uvm-scoreboard` | UVM Scoreboard 撰寫 |
| `/uvm-sequence` | UVM Sequence 撰寫 |
| `/uvm-test` | UVM Test 撰寫 |
| `/sv-interface` | SystemVerilog Interface 撰寫 |
| `/gen-component <type> <name>` | 生成 UVM 元件模板 |

---

## 學習筆記

### 2026/2/3 - APB3 協議基礎

#### 在整個 SoC 裡 APB3 扮演的角色

- 一般系統結構：CPU/主匯流排（AXI/AHB）→ Bridge（AXI/AHB-to-APB）→ APB 周邊（Timer/UART/GPIO…）
- Bridge 負責把「高性能匯流排的一筆讀寫」翻成「一筆 APB transfer」
- APB3 是 non-pipelined，一次只能處理一筆，狀態機非常簡單

#### 三個狀態：IDLE → SETUP → ACCESS

```
┌────────┐    PSEL=1     ┌────────┐    PENABLE=1   ┌────────┐
│  IDLE  │ ───────────▶  │ SETUP  │ ───────────▶   │ ACCESS │
│PSEL=0  │               │PSEL=1  │                │PSEL=1  │
│PENABLE=0               │PENABLE=0               │PENABLE=1│
└────────┘               └────────┘               └────────┘
    ▲                                                  │
    └──────────────── PREADY=1 ────────────────────────┘
```

**1. IDLE**
- 匯流排閒著，PSEL=0，PENABLE=0
- Master 決定是否發起下一筆傳輸

**2. SETUP（準備階段）**
- PSEL=1，PENABLE=0
- 設定 PADDR、PWRITE、PWDATA（若為寫入）
- 訊號在整個傳輸期間必須保持穩定

**3. ACCESS（實際存取階段）**
- PSEL=1，PENABLE=1
- PREADY=0：wait state，傳輸尚未完成
- PREADY=1：傳輸完成，下一拍回到 IDLE
- PSLVERR=1（在 PREADY=1 時）：傳輸失敗

#### 傳輸完成條件

```
完成點 = PSEL && PENABLE && PREADY (rising edge)
```

- **寫入**：Slave 在此 edge 把 PWDATA latch 進去
- **讀取**：Master 在此 edge 把 PRDATA latch 回來

#### PREADY / PSLVERR 實務

- **PREADY**：Slave 的握手信號，表示「這筆可以結算」
  - 簡單周邊可綁死為 1（不插 wait state）
  - 每筆傳輸固定兩拍（SETUP + ACCESS）

- **PSLVERR**：只在傳輸結束時有效
  - 典型用途：訪問 reserved 地址、illegal 配置

---

## 參考資料

- ARM AMBA 3 APB Protocol Specification
- SystemVerilog for Verification (book/)
- UVM 实战 卷Ⅰ (book/)
