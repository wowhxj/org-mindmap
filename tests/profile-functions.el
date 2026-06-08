(require 'org-mindmap)
(require 'elp)

;; Instrument all relevant functions
(dolist (fn '(
              ;; Layout functions
              org-mindmap-build-tree-layout
              org-mindmap-build-subtree
              org-mindmap--shift-subtree
              org-mindmap--center-subtree
              org-mindmap--get-occupied-rows
              org-mindmap--check-overlap-subtree
              org-mindmap--update-occupied-map
              org-mindmap--node-occupancy
              org-mindmap--node-box
              org-mindmap--node-display-lines
              org-mindmap--node-display-text
              org-mindmap--join-short-lines
              org-mindmap--min-row
              org-mindmap--max-row
              org-mindmap--min-column
              org-mindmap--descendants
              org-mindmap--subtree
              org-mindmap--side-children
              org-mindmap--side-descendants
              org-mindmap--side-is
              ;; Drawing functions
              org-mindmap-draw-subtree
              org-mindmap--move-to
              org-mindmap--connector-symbol
              org-mindmap--propertize-connector
              org-mindmap--propertize-text
              ;; Parsing functions
              org-mindmap-parser-parse-region
              org-mindmap-parser--go
              org-mindmap-parser--consume-node
              org-mindmap-parser--consume-text
              org-mindmap-parser--consume-spaces
              org-mindmap-parser--search-back
              org-mindmap-parser--join-continuations
              org-mindmap-parser--sort-tree
              org-mindmap-parser--find-explicit-root
              org-mindmap-parser--find-implicit-root
              org-mindmap-parser--snaps
              org-mindmap-parser--glue
              org-mindmap-parser--is-connector
              org-mindmap-parser--dirs
              org-mindmap-parser--get-symbol-registry
              org-mindmap-parser--mark-visited
              org-mindmap-parser--is-visited
              org-mindmap-parser--grid-get
              org-mindmap-parser--all-whitespaces
              org-mindmap--add-root-delimiters
              org-mindmap-render-tree
              org-mindmap-parse-properties
              org-mindmap--populate-properties
              org-mindmap--calculate-max-width
              ))
  (elp-instrument-function fn))

(defun benchmark-map-12-detailed ()
  (with-temp-buffer
    (org-mode)
    (insert "
* Test case: Large two-sided map with line wrapping.
#+begin_mindmap :layout centered :compacted t :max-width 15 :wrap-leaves 2
                                                                                                  ╭─ Идеи ┬─ вначале ── расплывчаты
                                                                                                  │       ╰─ потом ── уточняются
                                                                                                  │         ╭─ нелинейный ── новые идеи ── могут    ┬─ взгляд
                                                      можно положиться ─╮                         │         │  процесс                     изменить ╰─ следующие шаги
                                              запоминания ─┬ избавляет ─┤                         │         │         ╭─ быть         ── гибко
                                             отслеживания ─╯ от [fn:2]  │                         │         ├─ должно ┤  организовано
                                         содержании ─╮                  │                         │         │         ╰─ допускать ── небольшие    ── корректировки [fn:3]
                                         аргументах ─┤                  ├ Хорошая ─╮              │         │                         и постоянные
                                              идеях ─┼ сосредотачивает ─╯ система  │              │         │                                      ╭─ прочитать главу
           погружаетесь в ─╮                         │              на             │              ├─ Письмо ┤            ╭─ слишком ── чтобы       ┼─ найти ссылку
                   работу  ├ так, что ── одном деле ─╯                             │              │         │            │  малы       стоило      ╰─ записать мысль
     не прилагаете усилий ─╯                                                       │              │         │            │             фиксировать
                                           систему ── навязываете ─╮               │              │         ╰─ следующие ┤             ╭─ чтобы        ┬─ написать страницу
                                                             себе  ├ Планирование ─┤              │            шаги      ├─ слишком    ╯  фиксация     ╰─ написать статью
                демотивирует ── и это ── силу воли ── используете ─┤               │              │                      │  грандиозны    помогала    
                                           исследованию ── мешает ─╯               │              │                      │                их выполнять
                                                мышление ─┬ как и ─╮               │              │                      ╰─ сложно ── предугадать
                                                   учёба ─╯        │               │              │                         ╭─ делать то ── что не хотел
      идеей ─╮                                                     ├ Исследование ─┤              │         ╭─ не заставлял ┴─ 'Я пишу только    
  озарением ─┼ с каждой ── следующие ── корректировать ── требует ─╯               │         │  себя [fn:0]     тогда, когда сразу
достижением ─╯    новой         шаги                                               │         │                  знаю как'         
                                                    теорию ── разработать ─╮       │         ├─ два ящика ┬─ библиографический ── для источников
                                              записи ── систематизировать ─┼ Цель ─┤         │            ╰─ основной ── для своих мыслей
                                                       мысли ── развивать ─╯       │         │                     ╭─ библиографическую
                  заметками ── между ── связей ── из-за ── нарастает ─╮            │         ├─ когда ── записывал ┤  информацию       
                                          идеи ── зажигать ── нужна, ─┴ Сложность ─┤         │  читал              ╰─ краткие ── о ── содержании
                                                     новые     чтобы               ├ « Всё, что » ┤         │                        заметки
                                        темам ─┬ группировку ── через ─╮           │   вам надо   │         │        ╭─ просматривал ── заметки
                                     подтемам ─╯          по           │           │   знать      │         │        ├─ думал о ── значении ── в отношении ── своих ┬─ размышлений
                                                   упрощает ── на вид ─┤           │              │         │        │                                              ╰─ записей
                                               запутывает ── на самом ─┼ Простота ─┤              │         │        │            ╭─ идеи
                                                                 деле  │           │              │         │        │            ├─ комментарии
                         заметками ── между ── неожиданных ── снижает ─╯           │              │         │        │            ├─ мысли
                                                      веро    ятность              │              │         │        │            ├─ на новых  ── по одной
                                                в одном месте ── собрать ─╮        │              ╰─ Никлас ┼─ после ┼─ записывал ┤  карточках
                                                                     всё  │        │                 Луман  │  этого │  свои      │            ╭─ полными      
                                  способом ──    единым и ── разобраться ─┤        │                        │        │            ╰─ тщательно ┤  предложениями
                                              стандартным                 │        │                        │        │                         ╰─ с прямыми ── на литературу
                                           выбор ── делать ─╮             │        │                        │        │                            ссылками 
               в общую картину ── вписываетяс ── проверять ─┴ заставляет ─┤        │                        │        │                      ╭─ чтобы ── развить мысль
                                      ли дело                             │        │                        │        ╰─ добавлял ┬─ новую   ┼─ вслед за ── другой
                                       о делах ── перестать ─╮            ├ Дэвид ─╯                        │                    │  заметку ╰─ так, что ── получались ── цепочки записей
                                                     думать  ├ позволяет ─┤ Аллен                           │                    ╰─ ссылки ── на другие заметки
      'Разум подобен воде' ──   том, что ── сосредоточиться ─╯            │                                 │                   ╭─ не по темам
                              перед нами                 на               │                                 ├─ систематизировал ┼─ давал    ── абстрактные ── номера
                             нашего сознания ── исходят из ── отвлечения ─┤                                 │  [fn:1]           │  заметкам
                                           цели ──      чётко ─╮          │                                 │                   ╰─ чтобы ── навсегда ── идентифицировать
                                                   определить  ├ требует ─╯                                 │                                                      ╭─ комментарий
                                 маленькие шаги ──    разбить ─╯                                            │           ╭─ добавляя ── сразу ── другой ── например ┼─ дополнение
                                                   проекты на                                               ╰─ соединял ┤  заметку     после                       ╰─ исправление
                                                                                                                        ├─ указывая номер
                                                                                                                        ╰─ добавляя в ── отправные ┬─ тем
                                                                                                                           указатель     точки     ╰─ цепочек мыслей
#+end_mindmap")
    (let* ((region (org-mindmap-parser-get-region))
           (start (car region))
           (end (cdr region))
           (roots nil)
           (props (org-mindmap-parse-properties start)))
      ;; Reset profiler
      (elp-reset-all)

      ;; Benchmark Parsing
      (setq roots (org-mindmap-parser-parse-region start end))

      ;; Benchmark Layout
      (org-mindmap-build-tree-layout roots props)

      ;; Benchmark Drawing
      (with-temp-buffer
        (setq indent-tabs-mode nil)
        (let ((inhibit-read-only t))
          (dolist (root roots)
            (org-mindmap-draw-subtree root props))))

      ;; Show results
      (elp-results))))

(benchmark-map-12-detailed)
