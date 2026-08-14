# Report Spec

## Report identity
- Report name: Skyline Airline Passenger Satisfaction Analysis
- Semantic model: `Skyline_Airline_Passenger_Satisfaction_Analysis` (live, Power BI Desktop)
- Audience: Recruiters / hiring managers reviewing this as a portfolio piece
- Primary purpose: Prove end-to-end analytics skill (modeling, DAX, SQL, design) at a glance
- Delivery target: Local PBIP only for now; publishing decided later

## User decisions and constraints
- Scope: Redesign the existing single "Executive Summary" page + add 3 new pages (4 total)
- Page count: 4
- Interactivity: Slicers (year, cabin class, route type) synced across pages where relevant; native page-tab navigation (no drillthrough hierarchy needed for a 4-page flat report)
- Design direction: Modern Aviation Editorial — navy/sky-blue palette, clean sans-serif, card-based KPI tiles, aviation-inspired accents
- Publishing: Not now
- Tooling: `powerbi-modeling-mcp` connected live to Power BI Desktop (Tier 1); `powerbi-report-authoring` for PBIR mechanics
- Model edit permissions: Live model, write access confirmed (existing measures created earlier in this session's history)
- Accessibility: WCAG AA contrast, alt text on every visual, tabular numerals, no color-only encoding
- Data caveats: `warehouse vw_route_priority` is a point-in-time SQL-computed scorecard (DENSE_RANK/priority_score), not a time series — page 4's "MoM" story is carried by new DAX measures against `Dim Date`, not by that view

## Narrative
- Core story: Skyline's passengers are broadly satisfied and loyal, but a small set of routes/service touchpoints (delay, WiFi) are dragging down NPS and driving complaints — and the analysis pinpoints exactly where to intervene next.
- Audience promise: In under a minute, a recruiter sees KPIs, diagnostic depth, segmentation skill, and SQL/DAX-driven business recommendations — the full analytics skill stack.
- Key questions answered:
  1. Is the airline performing well overall? (Executive Summary)
  2. Why is satisfaction moving the way it is? (Service Quality & Operations)
  3. Who are the passengers and which routes matter most? (Customer & Route Insights)
  4. Where should the business act next, and what's the evidence? (Advanced Analytics & Recommendations)

## Design identity (from `powerbi-report-design` Step 1)
- Tone: Modern Aviation Editorial (custom remix of Editorial Newsroom + Corporate Cool) — navy/sky-blue palette, restrained accent use, clean sans-serif, generous whitespace, card-based KPI tiles
- Signature: Tabular-numeral KPI values + status-coded accent bars — every KPI card's accent bar reflects status (on-target navy/sky-blue, watch amber, risk red) against its own threshold, and every numeral in cards/tables/axes uses tabular alignment. Recurs on every page's KPI/context cards.
- Brownfield delta: current single Executive Summary page has no committed tone/signature (baseline theme) → target is the full identity above, applied consistently across all 4 pages

## Page plan (archetypes from `powerbi-report-design` Step 3)

1. **Executive Summary**
   - Archetype: Executive Summary
   - Layout variant: B — KPI-Strip (5 KPIs of comparable importance, no single dominant hero metric)
   - Purpose: State overall performance in ≤10s — passengers, satisfaction, NPS, revenue, complaints
   - Visuals: 5 KPI cards (status-coded accent bars) · Satisfaction Rate trend by month (line) · Complaint Rate by type, ranked (bar) · Service quality ratings comparison, sorted ascending (bar)
   - Fields/measures: Total Passengers, Satisfaction Rate, Average NPS, Total Revenue, Complaint Rate, Dim Date[Month Year], Fact[complainttype], 9 service-rating measures
   - Slicers/interactions: Year (dropdown), Cabin Class (tile), Route Type (tile) — synced group `GlobalFilters`

2. **Service Quality & Operations Deep Dive**
   - Archetype: Analytical Canvas
   - Layout variant: B — Inline-Slicers (3 slicers; content needs full width for the rolling-trend hero)
   - Purpose: Diagnose *why* satisfaction is moving — delay, complaints, service ratings, ops performance
   - Visuals: Rolling 30-day Satisfaction Rate vs. Average Delay (combo line, full width hero) · Complaint Rate by type (bar) · All 9 service ratings compared (clustered bar) · Average/Max Delay by route or aircraft family (bar) · Complaint driver detail table (route, type, count, rating)
   - Fields/measures: new `Rolling 30D Satisfaction Rate`, Average Delay, Maximum Delay, Complaint Rate, 9 service-rating measures, Dim Aircraft[aircraftfamily], Dim Flight[route]
   - Slicers/interactions: Year, Cabin Class, Route Type — synced `GlobalFilters`

3. **Customer & Route Insights**
   - Archetype: Analytical Canvas
   - Layout variant: C — Small-Multiples-Grid (comparing satisfaction/revenue across many segments and routes is the analytical point)
   - Purpose: Who are the passengers, and which routes/segments matter most?
   - Visuals: Small-multiples trellis of Satisfaction Rate by selectable segment dimension (new field parameter: age group / gender / loyalty tier / travel type / booking channel) · NPS by Loyalty Tier (ranked bar) · Cabin Class × Route Type satisfaction matrix (heatmap) · Revenue & NPS by top 10 routes (combo chart) · Top 10 routes performance spotlight table (with city/country from Dim Airport)
   - Fields/measures: new `Customer Segment` field parameter, Satisfaction Rate, Average NPS, Revenue per Passenger, Dim Passenger[*], Dim Booking[bookingchannel], Dim Airport[city/country], Dim Cabin[cabinclass]
   - Slicers/interactions: Customer Segment (field parameter, page-only), Cabin Class (tile, synced `GlobalFilters`)

4. **Advanced Analytics & Business Recommendations**
   - Archetype: Comparative Benchmark
   - Layout variant: A — Side-by-Side (ranked headline + small multiples; route count and priority scoring drive the comparison)
   - Purpose: Showcase the SQL/DAX analytics work (DENSE_RANK priority scoring, MoM/rolling trend, gap-to-benchmark) and translate it into concrete recommendations
   - Visuals: Route Priority Score ranked bar, top 15, colored by priority_category (headline) · Gap-to-benchmark callout (derived insight, not a duplicate measure) · Revenue vs. Satisfaction correlation scatter (size = passenger volume, color = priority_category) · MoM Satisfaction Rate trend (line, new DAX measure) · Business Recommendations panel (curated narrative textbox tied to the findings) · Full route ranking detail table
   - Fields/measures: `warehouse vw_route_priority` (priority_score, priority_category, satisfaction_rate, complaint_rate, average_delay, total_revenue), new `MoM Satisfaction Rate Δ`, new `Satisfaction Rate Gap vs Network Avg`
   - Slicers/interactions: Priority Category (tile, page-only), Route Type (tile, synced `GlobalFilters`)

## Design system summary
- Theme: adapted `assets/base.json`; page background `#F7F9FB` (soft aviation-sky tint), white visual containers, hairline dividers instead of heavy borders
- Color semantics: Total Passengers → Navy `#0B3D65` · Satisfaction Rate → Sky Blue `#2E86DE` (signature accent) · Average NPS → Teal `#12A594` · Total Revenue / Revenue per Passenger → Deep Gold `#B8860B` · Complaint Rate → Red `#D64550` (semantic negative) · Average/Max Delay → Slate Grey `#64748B`. Status-coded KPI accent bars: green `#1E9E6B` (on-target), amber `#E8A33D` (watch), red `#D64550` (risk). Route priority (Comparative page) uses a diverging RdBu ramp (`#2166AC` low-risk → `#B2182B` high-risk). Service-rating small multiples use the Okabe-Ito categorical set.
- Typography: Segoe UI throughout (no serif — avoids cross-platform rendering risk). Page titles 20pt SemiBold (exec) / 16pt SemiBold (analytical/comparative pages); KPI values 32pt Bold with tabular numerals; body/axis 9–10pt.
- Layout pattern: 12×12 grid, FHD 1920×1080, 32px margin, 24px gutter, 8px snap; reserved 1-row title/filter band on every page; slicers right-aligned inline (≤3 per page)
- Accessibility: WCAG AA contrast verified on navy/sky-blue-on-white and white-on-navy pairs; alt text on every chart; status never conveyed by color alone (icons/labels paired)

## Model requirements
- Existing measures (reused as-is): Total Passengers, Satisfaction Rate, Average NPS, Total Revenue, Revenue per Passenger, Complaint Rate, Average Delay, Maximum Delay, 9 service-rating averages (Food, WiFi, Seat Comfort, Crew, Boarding, Check-In, Cleanliness, Baggage Handling, Entertainment)
- New measures:
  - `Rolling 30D Satisfaction Rate` — trailing-30-day satisfaction rate over `Dim Date[fulldate]`
  - `MoM Satisfaction Rate Δ` — current vs. prior-month satisfaction rate (DATEADD)
  - `Satisfaction Rate Gap vs Network Avg` — route-level satisfaction rate minus the all-routes average (drives the page-4 callout's gap-to-benchmark basis)
- New calculated objects:
  - Field parameter `Customer Segment` (Dim Passenger[agegroup], Dim Passenger[gender], Dim Passenger[loyaltytier], Dim Passenger[traveltype], Dim Booking[bookingchannel]) for the page-3 trellis dimension picker
- Relationship/sort requirements: none — existing relationships (including the one-directional Flight→Airport chain and both-directional Booking/Passenger links) are sufficient; no changes needed
- Risk noted: `originairportkey` relationship is inactive — not used by this plan, so no `USERELATIONSHIP` needed

## Canonical design contract

```yaml
Design Brief:
  generated_by: powerbi-report-design
  contract_version: 1
  mode: brownfield
  design_identity:
    tone: "Modern Aviation Editorial — navy/sky-blue palette, restrained accent use, clean sans-serif, generous whitespace, card-based KPI tiles"
    signature: "Tabular-numeral KPI values + status-coded accent bars — every KPI/context card's accent bar reflects status against its own threshold; every numeral in cards/tables/axes uses tabular alignment. Recurs on every page."
    current_tone: "indistinct (single unstyled Executive Summary page, default theme)"
    current_signature: "none"
  archetype: multi (Executive Summary, Analytical Canvas x2, Comparative Benchmark)
  color_map:
    - measure: _Measures[Total Passengers]
      color: "#0B3D65"
      tint: "#D6E3EE"
    - measure: _Measures[Satisfaction Rate]
      color: "#2E86DE"
      tint: "#DCEBFB"
    - measure: _Measures[Average NPS]
      color: "#12A594"
      tint: "#D6F3EF"
    - measure: _Measures[Total Revenue]
      color: "#B8860B"
      tint: "#F3E6C4"
    - measure: _Measures[Revenue per Passenger]
      color: "#B8860B"
      tint: "#F3E6C4"
    - measure: _Measures[Complaint Rate]
      color: "#D64550"
      tint: "#F9DADC"
    - measure: _Measures[Average Delay]
      color: "#64748B"
      tint: "#E4E7EC"
    - measure: warehouse vw_route_priority[priority_score]
      color: "#B2182B"
      tint: "#2166AC"
      note: "diverging RdBu ramp, not single color: #2166AC (low-risk) -> #F7F7F7 (neutral) -> #B2182B (high-risk)"
  status_thresholds:
    - measure: _Measures[Satisfaction Rate]
      good: ">=0.75"
      watch: "0.60-0.75"
      risk: "<0.60"
    - measure: _Measures[Average NPS]
      good: ">=20"
      watch: "0-20"
      risk: "<0"
    - measure: _Measures[Complaint Rate]
      good: "<=0.05"
      watch: "0.05-0.10"
      risk: ">0.10"
    - measure: _Measures[Average Delay]
      good: "<=15"
      watch: "15-30"
      risk: ">30"
    good_color: "#1E9E6B"
    watch_color: "#E8A33D"
    risk_color: "#D64550"
  pages:
    - name: "Executive Summary"
      role: landing
      archetype: Executive
      layout_variant: B
      variant_rationale: "5 KPIs of comparable importance (Passengers, Satisfaction, NPS, Revenue, Complaints), no single dominant hero metric -> KPI-Strip."
      page_background: "#F7F9FB"
      layout_summary: "Title+filters band, full-width 5-card KPI strip with status-coded accent bars, satisfaction trend + complaint drivers side by side, service-quality snapshot bar along the bottom."
      layout_contract:
        canvas: { width: 1920, height: 1080, margin: 32, gutter: 24, snap: 8 }
        grid:
          columns: 12
          rows: 12
          regions:
            header:  [1, 1, 9, 2]
            filters: [9, 1, 13, 2]
            kpis:    [1, 2, 13, 4]
            trend:   [1, 4, 7, 9]
            hero:    [7, 4, 13, 9]
            detail:  [1, 9, 13, 13]
        placements:
          - id: page_title
            region: header
            kind: textbox
            text: "Skyline Passenger Satisfaction: Strong Loyalty, Delay-Driven Complaints"
            purpose: "State the page insight before any chart; wording to be re-verified against live KPI values at authoring time."
          - id: year_slicer
            region: filters
            kind: slicer
            field_bindings: Dim Date[yearnumber]
            slicer_type: dropdown
            slot: 1
            of: 3
          - id: cabin_slicer
            region: filters
            kind: slicer
            field_bindings: Dim Cabin[cabinclass]
            slicer_type: list
            slot: 2
            of: 3
          - id: routetype_slicer
            region: filters
            kind: slicer
            field_bindings: Dim Flight[routetype]
            slicer_type: list
            slot: 3
            of: 3
          - id: card_passengers
            region: kpis
            kind: cardVisual
            purpose: "How many passengers are we tracking?"
            field_bindings: _Measures[Total Passengers]
            color_strategy: measure_match
            slot: 1
            of: 5
          - id: card_satisfaction
            region: kpis
            kind: cardVisual
            purpose: "What share of passengers are satisfied?"
            field_bindings: _Measures[Satisfaction Rate]
            color_strategy: measure_match
            slot: 2
            of: 5
          - id: card_nps
            region: kpis
            kind: cardVisual
            purpose: "Would passengers recommend us?"
            field_bindings: _Measures[Average NPS]
            color_strategy: measure_match
            slot: 3
            of: 5
          - id: card_revenue
            region: kpis
            kind: cardVisual
            purpose: "How much revenue are we generating?"
            field_bindings: _Measures[Total Revenue]
            color_strategy: measure_match
            slot: 4
            of: 5
          - id: card_complaints
            region: kpis
            kind: cardVisual
            purpose: "How often are passengers complaining?"
            field_bindings: _Measures[Complaint Rate]
            color_strategy: measure_match
            slot: 5
            of: 5
          - id: satisfaction_trend
            region: trend
            kind: lineChart
            purpose: "How is satisfaction trending over time?"
            field_bindings: { Category: Dim Date[Month Year], Y: _Measures[Satisfaction Rate] }
            color_strategy: measure_match
          - id: complaint_drivers
            region: hero
            kind: barChart
            purpose: "Which complaint types drive the most dissatisfaction?"
            field_bindings: { Category: Fact Passenger Experience[complainttype], Y: _Measures[Complaint Rate] }
            sort_policy: value_desc
            color_strategy: gradient
          - id: service_quality_snapshot
            region: detail
            kind: barChart
            purpose: "Which service touchpoints are rated lowest?"
            field_bindings: { Category: "Service Rating Measure Name", Y: "Average Rating Value (0-5)" }
            sort_policy: value_asc
            color_strategy: gradient
        space_audit:
          content_cell_count: 132
          placed_cell_count: 132
          empty_cell_pct: 0
          unplaced_regions: []
          largest_region: { name: detail, pct_of_content: 36 }
          balance_rationale: "KPI strip, trend + complaint-driver panels, and the service-quality detail row all earn visible space; no unused footer or dead band."
      interaction_pattern:
        drill_targets: []
        cross_filter_rules: "All visuals cross-filter/highlight by default; slicers synced via GlobalFilters group."
      accessibility:
        alt_text_strategy: headline+trend
        contrast_notes: "Navy #0B3D65 and Sky Blue #2E86DE both exceed 4.5:1 on #F7F9FB and white."
      theme:
        base: "assets/base.json adapted with Modern Aviation Editorial dataColors"
        user_overrides: "none — brownfield page currently has no custom theme to preserve"

    - name: "Service Quality & Operations Deep Dive"
      role: detail
      archetype: Analytical
      layout_variant: B
      variant_rationale: "3 slicers (Year, Cabin, Route Type) is a small filter set (<50% rail fill) -> Inline-Slicers keeps full width for the rolling-trend hero."
      page_background: "#F7F9FB"
      layout_summary: "Full-width rolling-trend hero, three supporting panels (complaint type, service ratings, ops delay), complaint-driver detail table."
      layout_contract:
        canvas: { width: 1920, height: 1080, margin: 32, gutter: 24, snap: 8 }
        grid:
          columns: 12
          rows: 12
          regions:
            header:  [1, 1, 9, 2]
            filters: [9, 1, 13, 2]
            hero:    [1, 2, 13, 6]
            supp1:   [1, 6, 5, 9]
            supp2:   [5, 6, 9, 9]
            supp3:   [9, 6, 13, 9]
            detail:  [1, 9, 13, 13]
        placements:
          - id: page_title
            region: header
            kind: textbox
            text: "Delays and WiFi Are the Two Biggest Drags on Satisfaction"
            purpose: "State the diagnostic insight; wording re-verified against live query results at authoring time."
          - id: year_slicer
            region: filters
            kind: slicer
            field_bindings: Dim Date[yearnumber]
            slicer_type: dropdown
            slot: 1
            of: 3
          - id: cabin_slicer
            region: filters
            kind: slicer
            field_bindings: Dim Cabin[cabinclass]
            slicer_type: list
            slot: 2
            of: 3
          - id: routetype_slicer
            region: filters
            kind: slicer
            field_bindings: Dim Flight[routetype]
            slicer_type: list
            slot: 3
            of: 3
          - id: rolling_trend
            region: hero
            kind: lineChart
            purpose: "How is satisfaction trending on a rolling 30-day basis, and does it track with delay?"
            field_bindings: { Category: Dim Date[fulldate], Y1: "_Measures[Rolling 30D Satisfaction Rate]", Y2: _Measures[Average Delay] }
            color_strategy: measure_match
          - id: complaint_by_type
            region: supp1
            kind: barChart
            purpose: "Which complaint types are most frequent?"
            field_bindings: { Category: Fact Passenger Experience[complainttype], Y: _Measures[Complaint Rate] }
            sort_policy: value_desc
            color_strategy: gradient
          - id: service_ratings_compared
            region: supp2
            kind: barChart
            purpose: "How do all 9 service touchpoints compare?"
            field_bindings: { Category: "Service Rating Measure Name", Y: "Average Rating Value (0-5)" }
            sort_policy: value_asc
            color_strategy: unique
          - id: delay_by_aircraft
            region: supp3
            kind: barChart
            purpose: "Which aircraft families or routes run the most delay?"
            field_bindings: { Category: Dim Aircraft[aircraftfamily], Y: _Measures[Average Delay] }
            sort_policy: value_desc
            color_strategy: measure_match
          - id: complaint_detail_table
            region: detail
            kind: tableEx
            purpose: "Which specific route/complaint-type combinations need follow-up?"
            field_bindings: [Dim Flight[route], Fact Passenger Experience[complainttype], _Measures[Complaint Count], _Measures[Average Delay]]
        space_audit:
          content_cell_count: 132
          placed_cell_count: 132
          empty_cell_pct: 0
          unplaced_regions: []
          largest_region: { name: hero, pct_of_content: 36 }
          balance_rationale: "Rolling-trend hero explains the 'why', three supporting panels each answer a distinct diagnostic question, and the detail table surfaces the specific follow-up items."
      interaction_pattern:
        drill_targets: []
        cross_filter_rules: "Cross-filter/highlight by default; slicers synced via GlobalFilters group."
      accessibility:
        alt_text_strategy: chart+structure
        contrast_notes: "Gradient bars retain a labeled axis so color is never the sole encoding."
      theme:
        base: "assets/base.json adapted with Modern Aviation Editorial dataColors"
        user_overrides: none

    - name: "Customer & Route Insights"
      role: detail
      archetype: Analytical
      layout_variant: C
      variant_rationale: "The core question is comparison across many segments/routes on shared metrics (satisfaction, NPS, revenue) -> Small-Multiples-Grid, driven by a swappable Customer Segment field parameter."
      page_background: "#F7F9FB"
      layout_summary: "Segment trellis (field-parameter driven) + loyalty ranking, cabin/route matrix + route revenue chart, top-10 route spotlight table."
      layout_contract:
        canvas: { width: 1920, height: 1080, margin: 32, gutter: 24, snap: 8 }
        grid:
          columns: 12
          rows: 12
          regions:
            header:  [1, 1, 9, 2]
            filters: [9, 1, 13, 2]
            trellis: [1, 2, 9, 7]
            loyalty: [9, 2, 13, 7]
            matrix:  [1, 7, 7, 10]
            routes:  [7, 7, 13, 10]
            detail:  [1, 10, 13, 13]
        placements:
          - id: page_title
            region: header
            kind: textbox
            text: "Loyalty Tiers Are Satisfied — International Routes Are Where Revenue and Risk Concentrate"
            purpose: "State the segmentation insight; wording re-verified against live query results at authoring time."
          - id: segment_field_parameter
            region: filters
            kind: slicer
            field_bindings: "Customer Segment (field parameter: agegroup | gender | loyaltytier | traveltype | bookingchannel)"
            slicer_type: dropdown
            slot: 1
            of: 2
          - id: cabin_slicer
            region: filters
            kind: slicer
            field_bindings: Dim Cabin[cabinclass]
            slicer_type: list
            slot: 2
            of: 2
          - id: segment_trellis
            region: trellis
            kind: smallMultiplesChart
            purpose: "How does satisfaction vary across the selected segment dimension?"
            field_bindings: { Category: "Customer Segment (field parameter)", Y: _Measures[Satisfaction Rate] }
            color_strategy: measure_match
          - id: nps_by_loyalty
            region: loyalty
            kind: barChart
            purpose: "Which loyalty tiers are the strongest promoters?"
            field_bindings: { Category: Dim Passenger[loyaltytier], Y: _Measures[Average NPS] }
            sort_policy: value_desc
            color_strategy: measure_match
          - id: cabin_route_matrix
            region: matrix
            kind: matrix
            purpose: "Where do cabin class and route type combine to produce the lowest satisfaction?"
            field_bindings: { Rows: Dim Cabin[cabinclass], Columns: Dim Flight[routetype], Values: _Measures[Satisfaction Rate] }
            color_strategy: gradient
          - id: revenue_nps_by_route
            region: routes
            kind: lineAndClusteredColumnChart
            purpose: "Which top routes drive the most revenue, and how satisfied are their passengers?"
            field_bindings: { Category: Dim Flight[route], Column: _Measures[Total Revenue], Line: _Measures[Average NPS] }
            sort_policy: value_desc
            color_strategy: measure_match
          - id: top_routes_spotlight
            region: detail
            kind: tableEx
            purpose: "What's the full performance picture for the top 10 routes by volume?"
            field_bindings: [Dim Flight[route], Dim Airport[city], Dim Airport[country], _Measures[Total Passengers], _Measures[Satisfaction Rate], _Measures[Revenue per Passenger]]
        space_audit:
          content_cell_count: 132
          placed_cell_count: 132
          empty_cell_pct: 0
          unplaced_regions: []
          largest_region: { name: trellis, pct_of_content: 30 }
          balance_rationale: "Segment trellis leads (the page's core analytical move), loyalty/matrix/route panels each add a distinct comparison, and the top-10 table is a justified compact spotlight (not a full detail grid)."
      interaction_pattern:
        drill_targets: []
        cross_filter_rules: "Cross-filter/highlight by default; Customer Segment field parameter and Cabin Class are page-scoped (not synced globally, since they drive page-specific exploration)."
      accessibility:
        alt_text_strategy: comparison framing
        contrast_notes: "Matrix gradient cells retain numeric labels so color is never the sole encoding."
      theme:
        base: "assets/base.json adapted with Modern Aviation Editorial dataColors"
        user_overrides: none

    - name: "Advanced Analytics & Business Recommendations"
      role: landing
      archetype: Comparative
      layout_variant: A
      variant_rationale: "8+ routes need ranking by priority_score with supporting revenue/satisfaction breakdown -> Side-by-Side ranked headline + small multiples, without requiring true multi-period slope data."
      page_background: "#F7F9FB"
      layout_summary: "Ranked priority-score headline + gap-to-benchmark callout, correlation scatter + MoM trend, recommendations panel + full ranking table."
      layout_contract:
        canvas: { width: 1920, height: 1080, margin: 32, gutter: 24, snap: 8 }
        grid:
          columns: 12
          rows: 12
          regions:
            header:      [1, 1, 9, 2]
            filters:     [9, 1, 13, 2]
            headline:    [1, 2, 8, 6]
            callout:     [8, 2, 13, 6]
            scatter:     [1, 6, 7, 10]
            trend:       [7, 6, 13, 10]
            recommend:   [1, 10, 7, 13]
            ranking:     [7, 10, 13, 13]
        placements:
          - id: page_title
            region: header
            kind: textbox
            text: "Three Routes Account for the Priority Intervention List"
            purpose: "State the recommendation-driving insight; wording re-verified against live query results at authoring time."
          - id: priority_slicer
            region: filters
            kind: slicer
            field_bindings: "warehouse vw_route_priority[priority_category]"
            slicer_type: list
            slot: 1
            of: 2
          - id: routetype_slicer
            region: filters
            kind: slicer
            field_bindings: Dim Flight[routetype]
            slicer_type: list
            slot: 2
            of: 2
          - id: priority_ranked_bar
            region: headline
            kind: barChart
            purpose: "Which routes rank highest for intervention priority?"
            field_bindings: { Category: "warehouse vw_route_priority[route]", Y: "warehouse vw_route_priority[priority_score]" }
            sort_policy: value_desc
            color_strategy: semantic
          - id: priority_callout
            region: callout
            kind: textbox
            purpose: "Name the single most urgent finding with its evidence."
            insight_basis: "Top-ranked route's complaint rate and satisfaction-rate gap vs. the network average (Satisfaction Rate Gap vs Network Avg measure)."
          - id: revenue_satisfaction_scatter
            region: scatter
            kind: scatterChart
            purpose: "Do high-revenue routes also have high satisfaction, or is there a tradeoff?"
            field_bindings: { X: "warehouse vw_route_priority[total_revenue]", Y: "warehouse vw_route_priority[satisfaction_rate]", Size: "warehouse vw_route_priority[passenger_count]", Legend: "warehouse vw_route_priority[priority_category]" }
            color_strategy: semantic
          - id: mom_satisfaction_trend
            region: trend
            kind: lineChart
            purpose: "Is satisfaction improving or declining month over month?"
            field_bindings: { Category: Dim Date[Month Year], Y: "_Measures[MoM Satisfaction Rate Δ]" }
            color_strategy: measure_match
          - id: business_recommendations
            region: recommend
            kind: textbox
            purpose: "Translate the analysis into 3-4 concrete, curated recommendations."
            insight_basis: "Curated narrative tied to the priority ranking, complaint drivers (page 2), and segment findings (page 3); maintained as static text, not a dynamic Smart Narrative."
          - id: route_ranking_table
            region: ranking
            kind: tableEx
            purpose: "What's the complete ranked evidence behind the recommendations?"
            field_bindings: ["warehouse vw_route_priority[route]", "warehouse vw_route_priority[priority_category]", "warehouse vw_route_priority[priority_score]", "warehouse vw_route_priority[satisfaction_rate]", "warehouse vw_route_priority[complaint_rate]", "warehouse vw_route_priority[average_delay]"]
        space_audit:
          content_cell_count: 132
          placed_cell_count: 132
          empty_cell_pct: 0
          unplaced_regions: []
          largest_region: { name: headline, pct_of_content: 21 }
          balance_rationale: "No single region dominates; ranked headline, evidence callout, correlation scatter, trend, recommendations, and ranking table each occupy a proportionate, readable share of the page."
      interaction_pattern:
        drill_targets: []
        cross_filter_rules: "Cross-filter/highlight by default; Priority Category is page-scoped, Route Type synced via GlobalFilters."
      accessibility:
        alt_text_strategy: comparison framing
        contrast_notes: "Semantic priority colors (risk/watch/good) always paired with the priority_category text label, never color alone."
      theme:
        base: "assets/base.json adapted with Modern Aviation Editorial dataColors"
        user_overrides: none

  theme:
    base: "assets/base.json adapted"
    user_overrides: "Replace dataColors with the Modern Aviation Editorial palette; set page background #F7F9FB; preserve base.json's textbox/card/table per-type safeguards."
```

## Implementation notes

- Model changes: create 3 new DAX measures (`Rolling 30D Satisfaction Rate`, `MoM Satisfaction Rate Δ`, `Satisfaction Rate Gap vs Network Avg`) and 1 field parameter (`Customer Segment`) via `powerbi-modeling-mcp`, validated with `EVALUATE { [Measure] }` before use in visuals.
- PBIR/report authoring: rebuild the existing single page as "Executive Summary" (page 1) to match this design system, then generate pages 2-4 via `powerbi-report-authoring`, following the layout_contract geometry exactly.
- Validation: run the full Validation Checklist from the planning skill (PBIP structure, modeling guidelines, DAX measure tests, table refresh) plus the design pre-flight checklist (space audits, no unplaced regions, callout evidence rules, contrast).
- Desktop screenshot verification: reload Desktop and screenshot all 4 pages after build; fix any overlap, truncation, or contrast issues found.
- Publishing boundary: none for this round — local PBIP only.
- Risks: (1) `warehouse vw_route_priority` is a snapshot, not a time series, so the "MoM"/"rolling" story on pages 2 and 4 is carried by new fact-table DAX measures, not that view — flagged above. (2) No map visual is used for the "geographic view" ask on page 3; substituted with a route/city/country spotlight table to avoid Azure Map/Bing-key setup risk — call this out if a literal map is important to you. (3) The page-1 title, page-2 title, page-3 title, and page-4 title are all provisional insight-style titles; exact wording will be confirmed against live query results during authoring (kept in the same spirit, but numbers may shift the phrasing).
