-- Conjure：Lisp 系语言的交互式 REPL 求值。
-- 打开 .rkt 文件后第一次求值时会自动拉起 racket -i 子进程。
-- 常用键（localleader 已设为 "\"）：
--   \ee  求值光标下的 form      \er  求值最外层 form
--   \eb  求值整个 buffer        \ef  求值光标下的文件
--   \\   打开/关闭求值结果日志   \cq  关闭 REPL 连接
-- 完整列表见 :h conjure-mappings
return {
    "olical/conjure",
    ft = { "racket", "scheme", "clojure", "fennel", "janet" },
}
