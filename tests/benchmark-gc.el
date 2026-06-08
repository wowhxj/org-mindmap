;;; -*- lexical-binding: t -*-
;;; Benchmark: effect of gc-cons-percentage on org-mindmap performance
(require 'org-mindmap)

(defsubst benchmark-gc--conses ()
  "Return total conses from garbage-collect (alist format, Emacs 31+)."
  (nth 1 (assq 'conses (garbage-collect))))

(defun benchmark-map-12-gc-settings ()
  "Test the full parse→layout→draw pipeline with different gc-cons-percentage values."
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
  озарением ─┼ с каждой ── следующие ── корректировать ── требует ─╯               │              │         │  себя [fn:0]     тогда, когда сразу
достижением ─╯    новой         шаги                                               │              │         │                  знаю как'         
                                                    теорию ── разработать ─╮       │              │         ├─ два ящика ┬─ библиографический ── для источников
                                              записи ── систематизировать ─┼ Цель ─┤              │         │            ╰─ основной ── для своих мыслей
                                                       мысли ── развивать ─╯       │              │         │                     ╭─ библиографическую
                  заметками ── между ── связей ── из-за ── нарастает ─╮            │              │         ├─ когда ── записывал ┤  информацию       
                                          идеи ── зажигать ── нужна, ─┴ Сложность ─┤              │         │  читал              ╰─ краткие ── о ── содержании
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
           (end (cdr region)))
      ;; Warm-up: run once to initialize caches, load libraries, etc.
      (let* ((props (org-mindmap-parse-properties start))
             (roots (org-mindmap-parser-parse-region start end)))
        (org-mindmap-build-tree-layout roots props)
        (with-temp-buffer
          (setq indent-tabs-mode nil)
          (let ((inhibit-read-only t))
            (dolist (root roots)
              (org-mindmap-draw-subtree root props)))))

      (message "\n=== GC Benchmark Results (20 iterations each, avg ms) ===")
      (message "%-30s %10s %10s %10s %10s %s" "Setting" "Parse" "Layout" "Draw" "Total" "Δ Conses/iter")

      (dolist (cfg '((0.1 . "0.1 (default)")
                     (0.5 . "0.5")
                     (0.7 . "0.7")
                     (0.9 . "0.9")
                     (0.95 . "0.95")))
        (let* ((gcp (car cfg))
               (label (cdr cfg))
               (t-parse 0.0)
               (t-layout 0.0)
               (t-draw 0.0)
               (gc-total 0))
          (dotimes (_ 20)
            (garbage-collect) ;; Clean slate
            (let* ((gc-before (benchmark-gc--conses))
                   (gc-cons-percentage gcp)
                   (st (float-time))
                   (props (org-mindmap-parse-properties start))
                   (roots (org-mindmap-parser-parse-region start end)))
              (setq t-parse (+ t-parse (* 1000 (- (float-time) st))))
              (let ((st (float-time)))
                (org-mindmap-build-tree-layout roots props)
                (setq t-layout (+ t-layout (* 1000 (- (float-time) st)))))
              (let ((st (float-time)))
                (with-temp-buffer
                  (setq indent-tabs-mode nil)
                  (let ((inhibit-read-only t))
                    (dolist (root roots)
                      (org-mindmap-draw-subtree root props))))
                (setq t-draw (+ t-draw (* 1000 (- (float-time) st)))))
              (setq gc-total (+ gc-total (- (benchmark-gc--conses) gc-before)))))

          (message "%-30s %7.2f ms %7.2f ms %7.2f ms %7.2f ms %7.0f"
                   label
                   (/ t-parse 20.0) (/ t-layout 20.0) (/ t-draw 20.0)
                   (/ (+ t-parse t-layout t-draw) 20.0)
                   (/ gc-total 20.0))))

      ;; Also test the "standard" approach: gc-cons-threshold → most-positive-fixnum
      (let ((t-parse 0.0)
            (t-layout 0.0)
            (t-draw 0.0)
            (gc-total 0))
        (dotimes (_ 20)
          (garbage-collect)
          (let* ((gc-before (benchmark-gc--conses))
                 (gc-cons-threshold most-positive-fixnum)
                 (st (float-time))
                 (props (org-mindmap-parse-properties start))
                 (roots (org-mindmap-parser-parse-region start end)))
            (setq t-parse (+ t-parse (* 1000 (- (float-time) st))))
            (let ((st (float-time)))
              (org-mindmap-build-tree-layout roots props)
              (setq t-layout (+ t-layout (* 1000 (- (float-time) st)))))
            (let ((st (float-time)))
              (with-temp-buffer
                (setq indent-tabs-mode nil)
                (let ((inhibit-read-only t))
                  (dolist (root roots)
                    (org-mindmap-draw-subtree root props))))
              (setq t-draw (+ t-draw (* 1000 (- (float-time) st)))))
            (setq gc-total (+ gc-total (- (benchmark-gc--conses) gc-before)))))
        (message "%-30s %7.2f ms %7.2f ms %7.2f ms %7.2f ms %7.0f"
                 "threshold=most-positive-fixnum"
                 (/ t-parse 20.0) (/ t-layout 20.0) (/ t-draw 20.0)
                 (/ (+ t-parse t-layout t-draw) 20.0)
                 (/ gc-total 20.0)))

      ;; Combined approach
      (let ((t-parse 0.0)
            (t-layout 0.0)
            (t-draw 0.0)
            (gc-total 0))
        (dotimes (_ 20)
          (garbage-collect)
          (let* ((gc-before (benchmark-gc--conses))
                 (gc-cons-percentage 0.9)
                 (gc-cons-threshold most-positive-fixnum)
                 (st (float-time))
                 (props (org-mindmap-parse-properties start))
                 (roots (org-mindmap-parser-parse-region start end)))
            (setq t-parse (+ t-parse (* 1000 (- (float-time) st))))
            (let ((st (float-time)))
              (org-mindmap-build-tree-layout roots props)
              (setq t-layout (+ t-layout (* 1000 (- (float-time) st)))))
            (let ((st (float-time)))
              (with-temp-buffer
                (setq indent-tabs-mode nil)
                (let ((inhibit-read-only t))
                  (dolist (root roots)
                    (org-mindmap-draw-subtree root props))))
              (setq t-draw (+ t-draw (* 1000 (- (float-time) st)))))
            (setq gc-total (+ gc-total (- (benchmark-gc--conses) gc-before)))))
        (message "%-30s %7.2f ms %7.2f ms %7.2f ms %7.2f ms %7.0f"
                 "gcp=0.9 + thresh=most-pos-fixnum"
                 (/ t-parse 20.0) (/ t-layout 20.0) (/ t-draw 20.0)
                 (/ (+ t-parse t-layout t-draw) 20.0)
                 (/ gc-total 20.0))))))

(benchmark-map-12-gc-settings)
