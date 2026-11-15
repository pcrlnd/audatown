#[[
Header-only INTERFACE library that defines no-op error context macros
(ADD_EXCEPTION_CONTEXT). No error reports are collected or sent.
]]

set( TARGET au3-sentry-reporting )

audacity_header_only_library( ${TARGET} "SentryHelper.h" "" "" "" )
