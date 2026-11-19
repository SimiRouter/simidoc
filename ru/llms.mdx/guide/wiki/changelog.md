# История изменений

<Callout type="warn" title="Версии · Данные обновлены 2026-8-12 18:48:26">
  Полная история доступна на [странице GitHub Releases](https\://github.com/QuantumNous/new-api/releases). Данные на этой странице не обновляются в реальном времени; время последней синхронизации указано в заголовке этого блока. Если вышестоящий проект выпускает версии чаще, ориентируйтесь на него.
</Callout>

## v1.0.0-rc.24

<Callout type="info" title="Последняя запись на этой странице · Опубликована 2026-08-07 17:47:48 (время Китая)">
  ### Выпуск\: v1.0.0-rc.24

  #### Новые возможности

  * Добавлено ограничение частоты критичных пользовательских операций для маршрутов токенов доступа и партнерских переводов.
  * Улучшена классификация моделей, полученных каналами.

  #### Исправления

  * Исправлена потеря точности квоты кодов пополнения (#6685).
  * Исправлены прозрачные повторы HTTP/2 после сброса потока вышестоящим сервером благодаря правильной настройке `Request.GetBody` в ретрансляторе (#6249).
  * Тесты Claude и Gemini используют нативный формат запросов для совместимости.

  #### Прочее

  * В CI синхронизация выпусков дополнена необязательной синхронизацией файлов.

  ***

  ### Изменения

  * fix(relay)\: установка Request.GetBody для прозрачного повтора HTTP/2 после сброса потока — @BlockchainHe, [https\://github.com/QuantumNous/new-api/pull/6249](https\://github.com/QuantumNous/new-api/pull/6249)
  * feat(channels)\: улучшение классификации полученных моделей — @seefs001, [https\://github.com/QuantumNous/new-api/pull/6632](https\://github.com/QuantumNous/new-api/pull/6632)
  * fix\: тестирование Claude/Gemini в нативном формате — @seefs001, [https\://github.com/QuantumNous/new-api/pull/6698](https\://github.com/QuantumNous/new-api/pull/6698)
  * fix\: исправлена потеря точности квоты кодов пополнения (#6680) — @lihu-001, [https\://github.com/QuantumNous/new-api/pull/6685](https\://github.com/QuantumNous/new-api/pull/6685)

  ### Новые участники

  * @BlockchainHe впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/6249](https\://github.com/QuantumNous/new-api/pull/6249)
  * @lihu-001 впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/6685](https\://github.com/QuantumNous/new-api/pull/6685)

  **Полный список изменений**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.23...v1.0.0-rc.24](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.23...v1.0.0-rc.24)

  **Загрузки**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.24](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/new-api-arm64-v1.0.0-rc.24) (110.1 MB)
  * [new-api-macos-v1.0.0-rc.24](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/new-api-macos-v1.0.0-rc.24) (132.6 MB)
  * [new-api-v1.0.0-rc.24](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/new-api-v1.0.0-rc.24) (113.2 MB)
  * [new-api-v1.0.0-rc.24.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/new-api-v1.0.0-rc.24.exe) (115.1 MB)
  * [Исходный код (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.24.zip)
  * [Исходный код (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.24.tar.gz)
</Callout>

***

## v1.0.0-rc.23

<Callout type="note" title="Стабильный выпуск · Опубликован 2026-08-01 23:25:04 (время Китая)">
  Главное\: расширена совместимость каналов New API, DeepSeek Responses, распаковки zstd и автоматического выбора групп. Улучшены отображение потоков в журналах, расчет повторов многоуровневого тарифа и отмена Bedrock при отключении клиента.

  ### Новые возможности

  * Добавлены каналы New API\: потоковое преобразование Gemini в OpenAI, обработка Advanced Custom Responses Compact и multipart-редактирование изображений (#6559).
  * Добавлена поддержка DeepSeek Responses API (#6562).
  * Добавлен автоматический выбор группы маршрутизации (#6590).
  * Добавлены индивидуальные настройки HTTP-транспорта канала.
  * Добавлена поддержка сжатых запросов zstd (#6545).
  * Владельцы журналов видят, был ли запрос потоковым (#6558).

  ### Исправления

  * Qwen `thinking_budget` сохраняется при ретрансляции запросов (#5836).
  * Многоуровневые повторы тарифицируются по окончательно выбранной группе, включая смену группы (#6570).
  * При отключении клиента запросы Bedrock отменяются, сокращая лишнюю работу провайдера (#6589).

  ### Улучшения

  * Размер шрифта верхней публичной навигации унифицирован (#6557).

  ***

  ### Изменения

  * refactor\: выделение преобразования протоколов в отдельный модуль relaykit — @Calcium-Ion, [https\://github.com/QuantumNous/new-api/pull/6369](https\://github.com/QuantumNous/new-api/pull/6369)
  * fix\: параметры SQL в медленных запросах и ошибках журналируются безопасно — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/6493](https\://github.com/QuantumNous/new-api/pull/6493)
  * feat(oidc)\: настраиваемое отображаемое имя входа OIDC — @mrchi, [https\://github.com/QuantumNous/new-api/pull/6012](https\://github.com/QuantumNous/new-api/pull/6012)
  * fix\: сохранение Qwen thinking\_budget при передаче — @wxwwt, [https\://github.com/QuantumNous/new-api/pull/5836](https\://github.com/QuantumNous/new-api/pull/5836)
  * feat\: распаковка запросов zstd — @seefs001, [https\://github.com/QuantumNous/new-api/pull/6545](https\://github.com/QuantumNous/new-api/pull/6545)
  * feat(logs)\: отображение потокового режима владельцам журналов — @seefs001, [https\://github.com/QuantumNous/new-api/pull/6558](https\://github.com/QuantumNous/new-api/pull/6558)
  * fix(relay)\: сохранение multipart-редактирования изображений каналов New API — @seefs001, [https\://github.com/QuantumNous/new-api/pull/6559](https\://github.com/QuantumNous/new-api/pull/6559)
  * fix(oauth)\: чужой window\.opener больше не считается процессом привязки — @neimaravila, [https\://github.com/QuantumNous/new-api/pull/6425](https\://github.com/QuantumNous/new-api/pull/6425)
  * style\: единый шрифт публичной навигации 14px (text-sm) — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/6557](https\://github.com/QuantumNous/new-api/pull/6557)
  * feat\: DeepSeek Responses API — @seefs001, [https\://github.com/QuantumNous/new-api/pull/6562](https\://github.com/QuantumNous/new-api/pull/6562)
  * fix(billing)\: расчет повторов по окончательной группе — @faithleysath, [https\://github.com/QuantumNous/new-api/pull/6518](https\://github.com/QuantumNous/new-api/pull/6518)
  * fix(billing)\: усиление расчета при смене групп (продолжение #6518) — @Calcium-Ion, [https\://github.com/QuantumNous/new-api/pull/6570](https\://github.com/QuantumNous/new-api/pull/6570)
  * fix(aws)\: отмена Bedrock при отключении клиента — @Calcium-Ion, [https\://github.com/QuantumNous/new-api/pull/6589](https\://github.com/QuantumNous/new-api/pull/6589)
  * feat\: автоматический выбор группы — @Calcium-Ion, [https\://github.com/QuantumNous/new-api/pull/6590](https\://github.com/QuantumNous/new-api/pull/6590)

  ### Новые участники

  * @mrchi впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/6012](https\://github.com/QuantumNous/new-api/pull/6012)
  * @neimaravila впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/6425](https\://github.com/QuantumNous/new-api/pull/6425)
  * @faithleysath впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/6518](https\://github.com/QuantumNous/new-api/pull/6518)

  **Полный список изменений**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.22...v1.0.0-rc.23](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.22...v1.0.0-rc.23)

  **Загрузки**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.23](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/new-api-arm64-v1.0.0-rc.23) (110.1 MB)
  * [new-api-macos-v1.0.0-rc.23](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/new-api-macos-v1.0.0-rc.23) (132.6 MB)
  * [new-api-v1.0.0-rc.23](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/new-api-v1.0.0-rc.23) (113.2 MB)
  * [new-api-v1.0.0-rc.23.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/new-api-v1.0.0-rc.23.exe) (115.0 MB)
  * [Исходный код (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.23.zip)
  * [Исходный код (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.23.tar.gz)
</Callout>

***

## v1.0.0-rc.22

<Callout type="note" title="Стабильный выпуск · Опубликован 2026-07-26 21:19:04 (время Китая)">
  Расширено управление каналами и моделями\: поиск моделей провайдера, новые графические модели Gemini, настройки тарификации и Sub2API. Улучшена надежность потоков, цен, возвратов, управления пользователями и административных интерфейсов.

  ### Новые возможности

  * Каналы могут обнаруживать модели расширенных пользовательских и Codex-совместимых провайдеров (#6184).
  * Добавлены актуальные стабильные графические модели Gemini (#6371).
  * Добавлена настройка цен инструментов с каналами Sub2API и тарификацией alpha-search.
  * Поддержаны стабильные модели OpenAI Realtime с улучшенной маршрутизацией (#6032).

  ### Исправления

  * Потоковое преобразование Responses в Chat больше не дублирует инструменты (#6225).
  * Создание одноименной модели больше не удаляет сохраненные цены (#6365).
  * Список моделей без цены показывает только модели выбранных каналов (#6126).
  * Большие пользовательские квоты обрабатываются без переполнения (#6134).
  * Исправлена сортировка пользователей при пагинации (#6194).
  * Модели MiniMax правильно связаны с провайдером MiniMax (#6164).
  * Селекторы групп Playground корректно показывают автоматические группы и длинные пункты (#6163).
  * Параллельные обновления статуса больше не дублируют возвраты задач (#6074).
  * Поле суммы пополнения можно полностью очистить (#6473).
  * Повышена надежность быстрого изменения приоритета канала (#6415).

  ### Улучшения

  * Унифицирован редактор JSON администратора; устранены проблемы скрытого содержимого (#6421).
  * Поиск пользователей использует debounce для сокращения запросов (#6474).
  * Повышена совместимость и стабильность каналов через прокси (#6157).
  * При неясных ошибках провайдера журнал содержит полезные резервные сведения (#6431).

  ***

  ### Изменения

  * fix\: только модели выбранных каналов во вкладке без цены — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/6126](https\://github.com/QuantumNous/new-api/pull/6126)
  * fix\: удаление данных аутентификации при окончательном удалении пользователя — @seefs001, [https\://github.com/QuantumNous/new-api/pull/6168](https\://github.com/QuantumNous/new-api/pull/6168)
  * fix(users)\: предотвращение переполнения больших квот — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/6134](https\://github.com/QuantumNous/new-api/pull/6134)
  * fix\: определение MiniMax для его моделей — @fux-dev, [https\://github.com/QuantumNous/new-api/pull/6164](https\://github.com/QuantumNous/new-api/pull/6164)
  * fix\: серверная сортировка пользователей вместо сортировки отдельной страницы — @DawnMoon1542, [https\://github.com/QuantumNous/new-api/pull/6194](https\://github.com/QuantumNous/new-api/pull/6194)
  * fix(data-table)\: немедленное обновление таблицы при переключении колонок — @DawnMoon1542, [https\://github.com/QuantumNous/new-api/pull/6253](https\://github.com/QuantumNous/new-api/pull/6253)
  * fix\: устранение дублирования инструментов в потоке Responses-to-Chat — @nikuleo, [https\://github.com/QuantumNous/new-api/pull/6225](https\://github.com/QuantumNous/new-api/pull/6225)
  * feat(channel)\: обнаружение моделей Codex-провайдера — @seefs001, [https\://github.com/QuantumNous/new-api/pull/6184](https\://github.com/QuantumNous/new-api/pull/6184)
  * feat\: получение моделей расширенных пользовательских каналов — @seefs001, [https\://github.com/QuantumNous/new-api/pull/5971](https\://github.com/QuantumNous/new-api/pull/5971)
  * refactor(auth)\: замена сеансов панели на stateless-токены и управление сеансами — @Calcium-Ion, [https\://github.com/QuantumNous/new-api/pull/6329](https\://github.com/QuantumNous/new-api/pull/6329)
  * fix\: при проксировании GA моделей gpt-realtime больше не передается beta-флаг — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/6032](https\://github.com/QuantumNous/new-api/pull/6032)
  * fix(playground)\: устранение растягивания пунктов группы моделей — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/6120](https\://github.com/QuantumNous/new-api/pull/6120)
  * perf(data-table)\: распределение ширины колонки действий — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/6135](https\://github.com/QuantumNous/new-api/pull/6135)
  * fix(web)\: показ использованной квоты безлимитных ключей — @RedwindA, [https\://github.com/QuantumNous/new-api/pull/6224](https\://github.com/QuantumNous/new-api/pull/6224)
  * fix(channel)\: совместимость прокси-клиента и жизненный цикл кеша — @yyhhyyyyyy, [https\://github.com/QuantumNous/new-api/pull/6157](https\://github.com/QuantumNous/new-api/pull/6157)
  * fix(playground)\: список моделей автоматической группы — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/6163](https\://github.com/QuantumNous/new-api/pull/6163)
  * fix\: предотвращение повторного возврата Suno через CAS-обновление статуса — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/6074](https\://github.com/QuantumNous/new-api/pull/6074)
  * chore(github)\: перевод шаблонов задач на обязательные формы — @seefs001, [https\://github.com/QuantumNous/new-api/pull/6452](https\://github.com/QuantumNous/new-api/pull/6452)
  * fix(github)\: восстановление видимости форм задач — @seefs001, [https\://github.com/QuantumNous/new-api/pull/6454](https\://github.com/QuantumNous/new-api/pull/6454)
  * fix\: журналирование тела при пустой разобранной ошибке провайдера — @bigsongeth, [https\://github.com/QuantumNous/new-api/pull/6431](https\://github.com/QuantumNous/new-api/pull/6431)
  * fix\: создание модели не удаляет цены одноименной модели — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/6365](https\://github.com/QuantumNous/new-api/pull/6365)
  * fix(web/channel)\: стабильное быстрое изменение приоритета — @RedwindA, [https\://github.com/QuantumNous/new-api/pull/6415](https\://github.com/QuantumNous/new-api/pull/6415)
  * perf(json-editor)\: единое редактирование JSON администратора — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/6421](https\://github.com/QuantumNous/new-api/pull/6421)
  * feat\: стабильные gemini-3-pro-image и gemini-3.1-flash-image — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/6371](https\://github.com/QuantumNous/new-api/pull/6371)
  * feat\: ключи Tencent TokenHub по OpenAI-совместимому протоколу — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/6232](https\://github.com/QuantumNous/new-api/pull/6232)
  * fix\: полная очистка поля суммы пополнения — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/6473](https\://github.com/QuantumNous/new-api/pull/6473)
  * fix\: debounce поля поиска пользователей — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/6474](https\://github.com/QuantumNous/new-api/pull/6474)

  ### Новые участники

  * @fux-dev впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/6164](https\://github.com/QuantumNous/new-api/pull/6164)
  * @DawnMoon1542 впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/6194](https\://github.com/QuantumNous/new-api/pull/6194)
  * @nikuleo впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/6225](https\://github.com/QuantumNous/new-api/pull/6225)
  * @bigsongeth впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/6431](https\://github.com/QuantumNous/new-api/pull/6431)

  **Полный список изменений**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.21...v1.0.0-rc.22](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.21...v1.0.0-rc.22)

  **Загрузки**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.22](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/new-api-arm64-v1.0.0-rc.22) (109.9 MB)
  * [new-api-macos-v1.0.0-rc.22](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/new-api-macos-v1.0.0-rc.22) (132.4 MB)
  * [new-api-v1.0.0-rc.22](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/new-api-v1.0.0-rc.22) (113.0 MB)
  * [new-api-v1.0.0-rc.22.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/new-api-v1.0.0-rc.22.exe) (114.9 MB)
  * [Исходный код (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.22.zip)
  * [Исходный код (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.22.tar.gz)
</Callout>

***

## v1.0.0-rc.21

<Callout type="note" title="Стабильный выпуск · Опубликован 2026-07-11 23:01:26 (время Китая)">
  ### Главное

  Главное — тарификация записи кеша GPT-5.6\: OpenAI `cache_write_tokens` тарифицируются по ставке создания кеша с корректным учетом кешированных и некешированных входных токенов. Улучшены настройки цен, Playground, таблицы каналов и надежность учета.

  ### Новые возможности

  * Добавлена тарификация записи кеша GPT-5.6\: OpenAI `cache_write_tokens` оплачиваются по ставке создания кеша с согласованным учетом кешированных и некешированных входных токенов.
  * Страницы цен динамически учитывают группы и скрывают демонстрационные специальные группы (#5906).
  * В настройках цен появились вкладка моделей без цены, фильтры статуса и синхронизации (#6124).
  * В Playground добавлены панели настройки параметров чата и генерации (#6044).
  * Колонки каналов можно изменять вручную; таблица заполняет доступную ширину (#5948).
  * Журналы показывают временные метрики потока и сведения о задачах.
  * Расширены преобразование текстовых протоколов и пользовательская маршрутизация (#5825).

  ### Исправления

  * Перевод браузера больше не повреждает страницы React (#5963).
  * Можно добавлять имена моделей, отличающиеся только регистром, включая множественный выбор (#6061).
  * Уточнен расчет предварительной квоты и случаев обрыва графического потока.
  * Повышена надежность сброса подписок при параллельных обновлениях (#6057).
  * Исправлена синхронизация передаваемых полей Codex Responses (#6018).
  * Селекторы Playground обновляются при изменении моделей.
  * Пользовательский iframe главной страницы может переходить наверх после действия пользователя (#5955).
  * Восстановлена вставка в стандартных настройках соединения канала.

  ### Улучшения

  * Ускорены загрузка и отображение таблиц синхронизации цен провайдера (#6092).
  * Улучшены значки таблиц, цены, окна синхронизации и тема административного интерфейса.
  * Исправлены пути шрифтов в разных структурах рабочего пространства.

  ***

  ### Изменения

  * fix(web)\: перевод браузера не изменяет корни React — @cat0825, [https\://github.com/QuantumNous/new-api/pull/5963](https\://github.com/QuantumNous/new-api/pull/5963)
  * feat(web)\: ручная ширина столбцов списка каналов — @zuiho-kai, [https\://github.com/QuantumNous/new-api/pull/5948](https\://github.com/QuantumNous/new-api/pull/5948)
  * fix(web)\: таблица каналов заполняет доступную ширину — @zuiho-kai, [https\://github.com/QuantumNous/new-api/pull/6031](https\://github.com/QuantumNous/new-api/pull/6031)
  * chore\: удаление мертвых файлов, возвращенных коммитом запуска v1.0 — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/6041](https\://github.com/QuantumNous/new-api/pull/6041)
  * fix\: блокировка строк GORM v2 при сбросе подписок — @seefs001, [https\://github.com/QuantumNous/new-api/pull/6057](https\://github.com/QuantumNous/new-api/pull/6057)
  * feat(playground)\: панель параметров Playground — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/6044](https\://github.com/QuantumNous/new-api/pull/6044)
  * fix\: добавление различающихся регистром моделей во множественном выборе — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/6061](https\://github.com/QuantumNous/new-api/pull/6061)
  * fix\: скрытие демонстрационных специальных групп со страницы цен — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/5906](https\://github.com/QuantumNous/new-api/pull/5906)
  * perf(model-pricing)\: оптимизация таблиц синхронизации цен — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/6092](https\://github.com/QuantumNous/new-api/pull/6092)
  * fix(web)\: переход iframe наверх после действия пользователя — @Heykode, [https\://github.com/QuantumNous/new-api/pull/5955](https\://github.com/QuantumNous/new-api/pull/5955)
  * chore(deps)\: обновление golang.org/x/crypto с 0.51.0 до 0.52.0 — @dependabot\[bot], [https\://github.com/QuantumNous/new-api/pull/6096](https\://github.com/QuantumNous/new-api/pull/6096)
  * fix\: синхронизация полей передачи Codex Responses — @seefs001, [https\://github.com/QuantumNous/new-api/pull/6018](https\://github.com/QuantumNous/new-api/pull/6018)
  * feat\: расширенное преобразование текста и пользовательские маршруты — @Calcium-Ion, [https\://github.com/QuantumNous/new-api/pull/5825](https\://github.com/QuantumNous/new-api/pull/5825)
  * feat\: вкладка моделей без цены в настройках тарифов — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/6124](https\://github.com/QuantumNous/new-api/pull/6124)

  ### Новые участники

  * @cat0825 впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/5963](https\://github.com/QuantumNous/new-api/pull/5963)

  **Полный список изменений**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.20...v1.0.0-rc.21](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.20...v1.0.0-rc.21)

  **Загрузки**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.21](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/new-api-arm64-v1.0.0-rc.21) (129.6 MB)
  * [new-api-macos-v1.0.0-rc.21](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/new-api-macos-v1.0.0-rc.21) (152.2 MB)
  * [new-api-v1.0.0-rc.21](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/new-api-v1.0.0-rc.21) (132.8 MB)
  * [new-api-v1.0.0-rc.21.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/new-api-v1.0.0-rc.21.exe) (134.6 MB)
  * [Исходный код (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.21.zip)
  * [Исходный код (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.21.tar.gz)
</Callout>

***

## v1.0.0-rc.20

<Callout type="note" title="Стабильный выпуск · Опубликован 2026-07-07 21:46:39 (время Китая)">
  ### Главное

  Добавлены цены GPT-5.6 и очистка устаревших экземпляров. Исправлены крайние случаи квот и цен\: переводы наград кошелька и ввод десятичных коэффициентов.

  ### Новые возможности

  * Добавлены цены токенов GPT-5.6.
  * В сведениях системы добавлена очистка устаревших экземпляров (#5953).

  ### Исправления

  * Переводы наград кошелька учитывают настроенную единицу квоты, а не фиксированную (#5808).
  * Поля коэффициента группы допускают нормальный ввод десятичных значений, например `0.05` (#5995).
  * Для предварительного списания многоуровневых тарифов используется стандартная оценка токенов, улучшая расчет квоты.

  ***

  ### Изменения

  * fix\: поле Ratio сохраняет промежуточную десятичную запись и позволяет ввод 0.05 — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/5995](https\://github.com/QuantumNous/new-api/pull/5995)
  * feat(system-info)\: очистка устаревших экземпляров — @seefs001, [https\://github.com/QuantumNous/new-api/pull/5953](https\://github.com/QuantumNous/new-api/pull/5953)
  * fix(wallet)\: настроенные единицы квоты при переводе наград — @A-Words, [https\://github.com/QuantumNous/new-api/pull/5808](https\://github.com/QuantumNous/new-api/pull/5808)

  ### Новые участники

  * @A-Words впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/5808](https\://github.com/QuantumNous/new-api/pull/5808)

  **Полный список изменений**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.19-i18nfix.2...v1.0.0-rc.20](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.19-i18nfix.2...v1.0.0-rc.20)

  **Загрузки**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.20](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/new-api-arm64-v1.0.0-rc.20) (129.3 MB)
  * [new-api-macos-v1.0.0-rc.20](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/new-api-macos-v1.0.0-rc.20) (151.7 MB)
  * [new-api-v1.0.0-rc.20](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/new-api-v1.0.0-rc.20) (132.4 MB)
  * [new-api-v1.0.0-rc.20.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/new-api-v1.0.0-rc.20.exe) (134.2 MB)
  * [Исходный код (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.20.zip)
  * [Исходный код (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.20.tar.gz)
</Callout>

***

## v1.0.0-rc.19-i18nfix.2

<Callout type="note" title="Стабильный выпуск · Опубликован 2026-07-07 14:06:07 (время Китая)">
  Исправлена ошибка локализации

  **Загрузки**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/checksums-linux.txt) (200 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/checksums-macos.txt) (103 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/checksums-windows.txt) (101 B)
  * [new-api-arm64-v1.0.0-rc.19-i18nfix.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/new-api-arm64-v1.0.0-rc.19-i18nfix.2) (129.3 MB)
  * [new-api-macos-v1.0.0-rc.19-i18nfix.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/new-api-macos-v1.0.0-rc.19-i18nfix.2) (151.7 MB)
  * [new-api-v1.0.0-rc.19-i18nfix.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/new-api-v1.0.0-rc.19-i18nfix.2) (132.4 MB)
  * [new-api-v1.0.0-rc.19-i18nfix.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/new-api-v1.0.0-rc.19-i18nfix.2.exe) (134.2 MB)
  * [Исходный код (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.19-i18nfix.2.zip)
  * [Исходный код (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.19-i18nfix.2.tar.gz)
</Callout>

***

## v1.0.0-rc.19

<Callout type="note" title="Стабильный выпуск · Опубликован 2026-07-07 13:19:27 (время Китая)">
  ### Новые возможности

  * Администратор может сбрасывать квоты подписок и просматривать события их насыщения для аудита (#5952).
  * Новый интерфейс локализован на традиционный китайский zh-TW (#5942).

  ### Исправления

  * Исправлен расчет очень больших квот.

  ***

  ### Изменения

  * Локализация нового интерфейса на zh-TW — @MeowTechOpenSource, [https\://github.com/QuantumNous/new-api/pull/5942](https\://github.com/QuantumNous/new-api/pull/5942)
  * feat(subscription)\: действия администратора для сброса квоты — @seefs001, [https\://github.com/QuantumNous/new-api/pull/5952](https\://github.com/QuantumNous/new-api/pull/5952)

  ### Новые участники

  * @MeowTechOpenSource впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/5942](https\://github.com/QuantumNous/new-api/pull/5942)

  **Полный список изменений**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.18...v1.0.0-rc.19](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.18...v1.0.0-rc.19)

  **Загрузки**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.19](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/new-api-arm64-v1.0.0-rc.19) (129.3 MB)
  * [new-api-macos-v1.0.0-rc.19](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/new-api-macos-v1.0.0-rc.19) (151.7 MB)
  * [new-api-v1.0.0-rc.19](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/new-api-v1.0.0-rc.19) (132.4 MB)
  * [new-api-v1.0.0-rc.19.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/new-api-v1.0.0-rc.19.exe) (134.2 MB)
  * [Исходный код (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.19.zip)
  * [Исходный код (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.19.tar.gz)
</Callout>

***

## v1.0.0-rc.18

<Callout type="note" title="Стабильный выпуск · Опубликован 2026-07-07 01:16:57 (время Китая)">
  Уточнена проверка количества при тарификации для предотвращения ошибочных квот.

  **Исправления**

  * Улучшена проверка недопустимых и экстремальных значений количества в расчетах квоты и потребления.

  ***

  **Полный список изменений**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.17...v1.0.0-rc.18](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.17...v1.0.0-rc.18)

  **Загрузки**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.18](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/new-api-arm64-v1.0.0-rc.18) (128.9 MB)
  * [new-api-macos-v1.0.0-rc.18](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/new-api-macos-v1.0.0-rc.18) (151.4 MB)
  * [new-api-v1.0.0-rc.18](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/new-api-v1.0.0-rc.18) (132.0 MB)
  * [new-api-v1.0.0-rc.18.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/new-api-v1.0.0-rc.18.exe) (133.9 MB)
  * [Исходный код (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.18.zip)
  * [Исходный код (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.18.tar.gz)
</Callout>

***

## v1.0.0-rc.17

<Callout type="note" title="Стабильный выпуск · Опубликован 2026-07-06 22:37:46 (время Китая)">
  ### Главное

  Улучшены тесты каналов, коды пополнения, темы и веб-интерфейсы. Исправлены учет потребления, сборка классического интерфейса, обрывы потоков, квоты и длительность видео.

  ### Новые возможности

  * Управление кодами пополнения поддерживает фильтры статуса и очистку.
  * Редактирование коэффициентов групп стало понятнее, обработка JSON надежнее.
  * Ошибки активации кодов содержат более ясные сообщения.

  ### Исправления

  * Интеграция AI Elements читает вложенные данные потребления.
  * Восстановлена сборка классического интерфейса (#5892).
  * Для каналов Codex правильно отображаются настройки передачи полей (#5902).
  * Iframe главной страницы синхронизирует тему и язык (#5917).
  * Пользовательский HTML в Shadow DOM следует светлой и темной теме (#5890).
  * Вошедшие пользователи перенаправляются со страницы регистрации, как при входе и в классической теме (#5910).
  * После отключения клиента запись потокового ответа прекращается (#5710).
  * Исправлены квоты и длительность видео Ali после расчета баланса задач (#5923).
  * Ошибка DNS не ломает создание даты сборки (#5945).

  ### Улучшения

  * Окна тестирования моделей и каналов стали компактнее (#5886).
  * Оформление динамических цен согласовано с деталями журналов (#5905).
  * Улучшены мобильные карточки пользователей.
  * Уточнено предупреждение старого пополнения (#5855).

  ***

  ### Изменения

  * chore(deps-dev)\: обновление tmp с 0.2.5 до 0.2.7 в /electron — @dependabot\[bot], [https\://github.com/QuantumNous/new-api/pull/5147](https\://github.com/QuantumNous/new-api/pull/5147)
  * chore(web)\: обновление зависимостей стандартного интерфейса — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/5884](https\://github.com/QuantumNous/new-api/pull/5884)
  * perf(web)\: взаимодействие с окном тестирования каналов — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/5886](https\://github.com/QuantumNous/new-api/pull/5886)
  * fix(classic)\: восстановление сборки классического интерфейса — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/5892](https\://github.com/QuantumNous/new-api/pull/5892)
  * fix(channels)\: настройки передачи полей для Codex — @seefs001, [https\://github.com/QuantumNous/new-api/pull/5902](https\://github.com/QuantumNous/new-api/pull/5902)
  * fix\: единый стиль динамических цен и разделов деталей журнала — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/5905](https\://github.com/QuantumNous/new-api/pull/5905)
  * fix\: корректировка quota после расчета разницы задач и длительности видео Alibaba — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/5923](https\://github.com/QuantumNous/new-api/pull/5923)
  * fix(web)\: синхронизация темы и языка iframe главной страницы — @guoruqiang, [https\://github.com/QuantumNous/new-api/pull/5917](https\://github.com/QuantumNous/new-api/pull/5917)
  * fix(web)\: восстановлена светлая и темная тема HTML в изоляции Shadow DOM — @olwater, [https\://github.com/QuantumNous/new-api/pull/5890](https\://github.com/QuantumNous/new-api/pull/5890)
  * fix(web)\: перенаправление вошедших пользователей со страницы регистрации, согласованное со входом и classic (#5908) — @Heykode, [https\://github.com/QuantumNous/new-api/pull/5910](https\://github.com/QuantumNous/new-api/pull/5910)
  * feat\: уточнение старого предупреждения пополнения (#5851) — @Gravirei, [https\://github.com/QuantumNous/new-api/pull/5855](https\://github.com/QuantumNous/new-api/pull/5855)
  * fix\: прекращение устаревших записей потока после отключения клиента — @seefs001, [https\://github.com/QuantumNous/new-api/pull/5710](https\://github.com/QuantumNous/new-api/pull/5710)
  * fix\: обработка DNS при создании даты сборки — @seefs001, [https\://github.com/QuantumNous/new-api/pull/5945](https\://github.com/QuantumNous/new-api/pull/5945)

  ### Новые участники

  * @Heykode впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/5910](https\://github.com/QuantumNous/new-api/pull/5910)
  * @Gravirei впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/5855](https\://github.com/QuantumNous/new-api/pull/5855)

  **Полный список изменений**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.16...v1.0.0-rc.17](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.16...v1.0.0-rc.17)

  **Загрузки**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.17](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/new-api-arm64-v1.0.0-rc.17) (128.9 MB)
  * [new-api-macos-v1.0.0-rc.17](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/new-api-macos-v1.0.0-rc.17) (151.4 MB)
  * [new-api-v1.0.0-rc.17](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/new-api-v1.0.0-rc.17) (132.0 MB)
  * [new-api-v1.0.0-rc.17.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/new-api-v1.0.0-rc.17.exe) (133.8 MB)
  * [Исходный код (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.17.zip)
  * [Исходный код (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.17.tar.gz)
</Callout>

***

## v1.0.0-rc.16

<Callout type="note" title="Стабильный выпуск · Опубликован 2026-07-03 15:41:42 (время Китая)">
  **Главное**

  Расширена совместимость Responses/Chat, Doubao Seedance 2.0 и медиаданных Wan2.7 i2v. Улучшены Playground, каналы, сохранение состояния страниц и корректное завершение работы.

  **Новые возможности**

  * Добавлено преобразование Responses API в Chat для совместимости клиентов и провайдеров (#5787).
  * Seedance 2.0 поддерживает API материалов, тарифы разрешения, видеоввода и 4K, новые параметры (#5824).
  * Добавлено отображение медиа Wan2.7 image-to-video (#4984).
  * Добавлено корректное завершение работы для сокращения оборванных ответов и потерь кеша при рестарте (#4258).
  * Улучшены макет управления каналами и расширенный редактор маршрутов.

  **Исправления**

  * Редактор выражений тарифов обновляется при смене моделей (#5752).
  * Потребление асинхронной задачи относится к инициировавшему узлу (#5684).
  * Смена темы возвращает на главную, а не на 404 (#5612).
  * Пользовательские HTML и Markdown сохраняют единые стили и интервалы, включая изолированные представления (#5795).
  * Исправлен сброс состояния при смене вкладок одного маршрута, включая диапазон панели (#5796).
  * Фильтр статуса каналов сохраняется при переходах (#5863).
  * Исправлены непотоковые вызовы инструментов Ollama (#5865).
  * Исправлены данные товаров и webhook Waffo (#5704).

  **Улучшения**

  * Улучшены чат Playground и Markdown (#5217).
  * Упрощены действия таблиц и подтверждение опасных операций (#5645).
  * Улучшена фильтрация LIKE журналов ClickHouse.
  * Ускорена сборка фронтенда (#5786).

  ***

  ### Изменения

  * chore(deps)\: обновление dompurify с 3.4.5 до 3.4.11 в /web/default — @dependabot\[bot], [https\://github.com/QuantumNous/new-api/pull/5718](https\://github.com/QuantumNous/new-api/pull/5718)
  * fix(ci)\: установка зависимостей классического интерфейса для выпусков — @seefs001, [https\://github.com/QuantumNous/new-api/pull/5719](https\://github.com/QuantumNous/new-api/pull/5719)
  * perf(web)\: действия таблиц и диалоги опасных операций — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/5645](https\://github.com/QuantumNous/new-api/pull/5645)
  * fix\: сведения товаров Waffo и обновление SDK webhook — @zhongyuanzhao-alt, [https\://github.com/QuantumNous/new-api/pull/5704](https\://github.com/QuantumNous/new-api/pull/5704)
  * fix(model-pricing)\: обновление редактора тарифов при смене модели — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/5752](https\://github.com/QuantumNous/new-api/pull/5752)
  * fix\: синхронизация bun.lock с dompurify 3.4.11 для frozen-lockfile — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/5738](https\://github.com/QuantumNous/new-api/pull/5738)
  * fix(theme)\: после смены фронтенда переход на главную предотвращает 404 — @zhangzhichaolove, [https\://github.com/QuantumNous/new-api/pull/5612](https\://github.com/QuantumNous/new-api/pull/5612)
  * fix(task)\: потребление асинхронной задачи относится к инициировавшему узлу — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/5684](https\://github.com/QuantumNous/new-api/pull/5684)
  * feat\: административные разрешения Casbin — @Calcium-Ion, [https\://github.com/QuantumNous/new-api/pull/5755](https\://github.com/QuantumNous/new-api/pull/5755)
  * feat(playground)\: улучшение чата Playground и Markdown — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/5217](https\://github.com/QuantumNous/new-api/pull/5217)
  * fix(auth)\: единый текст проверки пароля — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/5759](https\://github.com/QuantumNous/new-api/pull/5759)
  * fix(web)\: единое отображение пользовательских HTML и Markdown — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/5760](https\://github.com/QuantumNous/new-api/pull/5760)
  * fix(openai)\: усиление совместимости Chat-to-Responses — @Calcium-Ion, [https\://github.com/QuantumNous/new-api/pull/5772](https\://github.com/QuantumNous/new-api/pull/5772)
  * feat\: преобразование Responses в Chat — @Calcium-Ion, [https\://github.com/QuantumNous/new-api/pull/5787](https\://github.com/QuantumNous/new-api/pull/5787)
  * feat\: расчет doubao-seedance-2-0-260128 по разрешению — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/5300](https\://github.com/QuantumNous/new-api/pull/5300)
  * feat\: safety\_identifier/priority и тарификация 4K для Seedance 2.0 — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/5824](https\://github.com/QuantumNous/new-api/pull/5824)
  * fix(web)\: фильтрация CSS пользовательского HTML и интервалы верстки — @olwater, [https\://github.com/QuantumNous/new-api/pull/5795](https\://github.com/QuantumNous/new-api/pull/5795)
  * feat\: отображение медиа Wan2.7 i2v — @wxwwt, [https\://github.com/QuantumNous/new-api/pull/4984](https\://github.com/QuantumNous/new-api/pull/4984)
  * perf(web)\: оптимизация сборки Rsbuild и Tailwind — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/5786](https\://github.com/QuantumNous/new-api/pull/5786)
  * fix(makefile)\: dev-web запускает только стандартный веб-сервер разработки — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/5794](https\://github.com/QuantumNous/new-api/pull/5794)
  * fix(web)\: внедрение стилей приложения в изолированный HTML — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/5860](https\://github.com/QuantumNous/new-api/pull/5860)
  * fix\: сохранение состояния при смене вкладок одного маршрута — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/5796](https\://github.com/QuantumNous/new-api/pull/5796)
  * Корректное завершение сервиса предотвращает прерывание ответов и потерю кеша панели — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/4258](https\://github.com/QuantumNous/new-api/pull/4258)
  * fix\: только 401 считается истечением сеанса в защите стандартной темы — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/5872](https\://github.com/QuantumNous/new-api/pull/5872)
  * fix\: сохранение фильтра статуса каналов при переходах — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/5863](https\://github.com/QuantumNous/new-api/pull/5863)
  * chore(deps)\: обновление golang.org/x/net с 0.50.0 до 0.55.0 — @dependabot\[bot], [https\://github.com/QuantumNous/new-api/pull/5862](https\://github.com/QuantumNous/new-api/pull/5862)
  * chore(deps)\: обновление golang.org/x/image с 0.38.0 до 0.41.0 — @dependabot\[bot], [https\://github.com/QuantumNous/new-api/pull/5873](https\://github.com/QuantumNous/new-api/pull/5873)
  * fix\: непотоковые вызовы инструментов Ollama — @stevenjoezhang, [https\://github.com/QuantumNous/new-api/pull/5865](https\://github.com/QuantumNous/new-api/pull/5865)

  ### Новые участники

  * @zhangzhichaolove впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/5612](https\://github.com/QuantumNous/new-api/pull/5612)
  * @olwater впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/5795](https\://github.com/QuantumNous/new-api/pull/5795)
  * @wxwwt впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/4984](https\://github.com/QuantumNous/new-api/pull/4984)
  * @stevenjoezhang впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/5865](https\://github.com/QuantumNous/new-api/pull/5865)

  **Полный список изменений**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.15...v1.0.0-rc.16](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.15...v1.0.0-rc.16)

  **Загрузки**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.16](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/new-api-arm64-v1.0.0-rc.16) (127.4 MB)
  * [new-api-macos-v1.0.0-rc.16](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/new-api-macos-v1.0.0-rc.16) (149.8 MB)
  * [new-api-v1.0.0-rc.16](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/new-api-v1.0.0-rc.16) (130.5 MB)
  * [new-api-v1.0.0-rc.16.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/new-api-v1.0.0-rc.16.exe) (132.3 MB)
  * [Исходный код (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.16.zip)
  * [Исходный код (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.16.tar.gz)
</Callout>

***

## v1.0.0-rc.15

<Callout type="note" title="Стабильный выпуск · Опубликован 2026-06-24 21:00:04 (время Китая)">
  ### Главное

  Добавлены средства эксплуатации\: пассивный мониторинг каналов, хранение журналов ClickHouse, системные задачи и сведения об экземплярах. Улучшены журналы потребления, Markdown, выбор каналов и необязательный кошелек.

  ### Новые возможности

  * Добавлен пассивный мониторинг здоровья каналов без активного вмешательства в трафик (#5592).
  * Добавлено масштабируемое хранение и поиск журналов ClickHouse (#5663).
  * Добавлен исполнитель системных задач с сохранением прогресса длительной очистки (#5680).
  * Добавлена панель состояния экземпляров и узлов (#5716).
  * В системные настройки добавлен раздел лимита пользовательских токенов (#5678).
  * Добавлены выбор окружения теста канала и задержка асинхронного опроса.
  * Имя узла по умолчанию равно имени хоста, если `NODE_NAME` не задан (#5659).

  ### Исправления

  * Журналы потребления правильно показывают значки китайских моделей (#5631).
  * Исправлено отображаемое имя Stepfun (#5636).
  * Исправлена поддержка SMTP STARTTLS и NTLM (#5426).
  * Исправлена сборка классической темы при обработке часовых поясов (#5676).
  * Улучшен Markdown и расширен синтаксис веб-интерфейса (#5689).
  * Состояние карточки синхронизируется с выбранным каналом (#5700).
  * При отключенном кошельке его пункт скрыт в меню профиля (#5708).

  ### Улучшения

  * Упрощена очистка журналов в процессах обслуживания ClickHouse и системных задач.

  ***

  ### Изменения

  * fix(usage-logs)\: значки китайских провайдеров, как в классическом интерфейсе — @DeliciousBuding, [https\://github.com/QuantumNous/new-api/pull/5631](https\://github.com/QuantumNous/new-api/pull/5631)
  * fix\: переименование StepFun в Stepfun — @seefs001, [https\://github.com/QuantumNous/new-api/pull/5636](https\://github.com/QuantumNous/new-api/pull/5636)
  * feat\: пассивный мониторинг каналов — @exherb, [https\://github.com/QuantumNous/new-api/pull/5592](https\://github.com/QuantumNous/new-api/pull/5592)
  * feat\: имя узла по хосту при незаданном NODE\_NAME — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/5659](https\://github.com/QuantumNous/new-api/pull/5659)
  * feat\: база журналов ClickHouse — @Calcium-Ion, [https\://github.com/QuantumNous/new-api/pull/5663](https\://github.com/QuantumNous/new-api/pull/5663)
  * fix\: SMTP STARTTLS и NTLM — @bensonfx, [https\://github.com/QuantumNous/new-api/pull/5426](https\://github.com/QuantumNous/new-api/pull/5426)
  * chore(deps)\: обновление github.com/ClickHouse/ch-go с 0.58.2 до 0.65.0 — @dependabot\[bot], [https\://github.com/QuantumNous/new-api/pull/5664](https\://github.com/QuantumNous/new-api/pull/5664)
  * fix\: сборка классической темы с date-fns-tz — @seefs001, [https\://github.com/QuantumNous/new-api/pull/5676](https\://github.com/QuantumNous/new-api/pull/5676)
  * feat\: исполнитель системных задач — @Calcium-Ion, [https\://github.com/QuantumNous/new-api/pull/5680](https\://github.com/QuantumNous/new-api/pull/5680)
  * feat\: панель системных экземпляров — @Calcium-Ion, [https\://github.com/QuantumNous/new-api/pull/5716](https\://github.com/QuantumNous/new-api/pull/5716)
  * fix(web)\: замена Markdown-рендерера и расширение синтаксиса — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/5689](https\://github.com/QuantumNous/new-api/pull/5689)
  * fix(web)\: синхронизация выбора карточки канала — @yyhhyyyyyy, [https\://github.com/QuantumNous/new-api/pull/5700](https\://github.com/QuantumNous/new-api/pull/5700)
  * fix(web)\: скрытие отключенного кошелька в меню профиля — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/5708](https\://github.com/QuantumNous/new-api/pull/5708)
  * feat(system-settings)\: лимит пользовательских токенов — @RedwindA, [https\://github.com/QuantumNous/new-api/pull/5678](https\://github.com/QuantumNous/new-api/pull/5678)

  ### Новые участники

  * @DeliciousBuding впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/5631](https\://github.com/QuantumNous/new-api/pull/5631)
  * @exherb впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/5592](https\://github.com/QuantumNous/new-api/pull/5592)

  **Полный список изменений**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.14...v1.0.0-rc.15](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.14...v1.0.0-rc.15)

  **Загрузки**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.15](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/new-api-arm64-v1.0.0-rc.15) (131.4 MB)
  * [new-api-macos-v1.0.0-rc.15](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/new-api-macos-v1.0.0-rc.15) (153.3 MB)
  * [new-api-v1.0.0-rc.15](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/new-api-v1.0.0-rc.15) (134.2 MB)
  * [new-api-v1.0.0-rc.15.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/new-api-v1.0.0-rc.15.exe) (136.0 MB)
  * [Исходный код (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.15.zip)
  * [Исходный код (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.15.tar.gz)
</Callout>

***

## v1.0.0-rc.14

<Callout type="note" title="Стабильный выпуск · Опубликован 2026-06-20 22:15:42 (время Китая)">
  ### Главное

  Добавлена диаграмма потоков Санки для маршрутизации токенов\: подсветка, сохранение фильтров и ограничения размера графа. Новые карточки каналов ускоряют просмотр и сокращают повторную отрисовку.

  ### Новые возможности

  * Добавлена диаграмма Санки для наглядного анализа потоков токенов и маршрутизации (#5465).
  * Добавлено управление надежностью маршрутов с улучшенным контролем и наблюдаемостью.

  ### Галерея

  | Диаграмма потоков                                                                                                        | Карточки управления каналами                                                                                                  |
  | ------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------- |
  | ![Пример карточек управления каналами](https\://github.com/user-attachments/assets/e0d82bd4-e052-4518-9fac-1144c0bd0721) | ![Иллюстрация галереи примечаний к выпуску](https\://github.com/user-attachments/assets/2ab5e6e6-f4f7-44f5-9abd-7191ed30e7aa) |

  ### Исправления

  * Исправлена фильтрация журналов по типу входа в новом интерфейсе (#5620).
  * Исправлено перекрытие списка пагинацией в истории расчетов (#5627).
  * Исправлено удаление цен из визуального списка (#5628).
  * Устранены повторные миграции колонок после рестарта (#5361, #5616).

  ### Улучшения

  * Улучшены карточки каналов и сокращены лишние отрисовки.
  * Упрощен список моделей для просмотра и управления.
  * Унифицированы значки каналов.

  ***

  ### Изменения

  * fix\: прекращение повторной миграции allow\_balance\_pay при рестарте — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/5361](https\://github.com/QuantumNous/new-api/pull/5361)
  * fix\: прекращение повторной миграции allow\_wallet\_overflow при рестарте — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/5616](https\://github.com/QuantumNous/new-api/pull/5616)
  * feat(dashboard)\: диаграмма Sankey для потока токенов — @Quaternijkon, [https\://github.com/QuantumNous/new-api/pull/5465](https\://github.com/QuantumNous/new-api/pull/5465)
  * fix(log)\: фильтр нового фронтенда по типу входа type=7 — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/5620](https\://github.com/QuantumNous/new-api/pull/5620)
  * fix(wallet)\: перекрытие пагинации списком истории оплаты (#5624) — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/5627](https\://github.com/QuantumNous/new-api/pull/5627)
  * fix(model-pricing)\: восстановлено удаление ценовых элементов (#5623) — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/5628](https\://github.com/QuantumNous/new-api/pull/5628)

  ### Новые участники

  * @Quaternijkon впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/5465](https\://github.com/QuantumNous/new-api/pull/5465)

  **Полный список изменений**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.13...v1.0.0-rc.14](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.13...v1.0.0-rc.14)

  **Загрузки**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.14](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/new-api-arm64-v1.0.0-rc.14) (122.9 MB)
  * [new-api-macos-v1.0.0-rc.14](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/new-api-macos-v1.0.0-rc.14) (142.3 MB)
  * [new-api-v1.0.0-rc.14](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/new-api-v1.0.0-rc.14) (125.4 MB)
  * [new-api-v1.0.0-rc.14.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/new-api-v1.0.0-rc.14.exe) (127.1 MB)
  * [Исходный код (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.14.zip)
  * [Исходный код (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.14.tar.gz)
</Callout>

***

## v1.0.0-rc.13

<Callout type="note" title="Стабильный выпуск · Опубликован 2026-06-19 20:28:34 (время Китая)">
  v1.0.0-rc.13 улучшает отзывчивость и оформление интерфейса, особенно каналов и страниц с большими объемами данных. Добавлены карточки каналов и мобильный макет; обновлены журналы, метрики, выбор API, дат и представления потребления.

  ### Новые возможности

  * Добавлен переиспользуемый переключатель карточек и таблицы с новым макетом для разных экранов.
  * Формат чисел учитывает языковые и региональные настройки.

  ### Улучшения

  * Улучшена двухчастная структура карточек каналов и мобильное отображение.
  * Улучшены журналы, метрики, выбор API, календарь, панели инструментов и сведения модели.
  * Обновлен интерфейс потребления Codex (#5595).
  * Сокращены лишние обновления данных при возврате фокуса браузеру.
  * Унифицированы брендовые тексты и оформление фронтенда.

  ### Исправления

  * В представлениях рисования время при необходимости включает миллисекунды.

  ***

  ### Изменения

  * chore(web)\: обязательные проверки качества oxc для стандартного интерфейса — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/5585](https\://github.com/QuantumNous/new-api/pull/5585)
  * refactor\: интерфейс потребления Codex — @seefs001, [https\://github.com/QuantumNous/new-api/pull/5595](https\://github.com/QuantumNous/new-api/pull/5595)

  **Полный список изменений**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.12...v1.0.0-rc.13](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.12...v1.0.0-rc.13)

  **Загрузки**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.13](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/new-api-arm64-v1.0.0-rc.13) (122.9 MB)
  * [new-api-macos-v1.0.0-rc.13](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/new-api-macos-v1.0.0-rc.13) (142.2 MB)
  * [new-api-v1.0.0-rc.13](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/new-api-v1.0.0-rc.13) (125.3 MB)
  * [new-api-v1.0.0-rc.13.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/new-api-v1.0.0-rc.13.exe) (127.0 MB)
  * [Исходный код (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.13.zip)
  * [Исходный код (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.13.tar.gz)
</Callout>

***

## v1.0.0-rc.12

<Callout type="note" title="Стабильный выпуск · Опубликован 2026-06-18 20:34:16 (время Китая)">
  Главное\: каналы AdvancedCustom расширяют маршрутизацию, пакетные тесты стали удобнее, мониторинг витрины показывает успешность и задержки.

  ### Новые возможности

  * Добавлены AdvancedCustom с улучшенным сопоставлением пользовательских маршрутов (#5590).
  * Пакетный тест моделей выполняется полностью, обновляет состояния и результаты, позволяет удалять сбойные и копировать выбранные модели (#5532).
  * Мониторинг витрины дополнен временем доступности, недавней успешностью, ее оценкой и компактными метриками задержки/производительности.
  * Предпочтения размера страницы и колонок сохраняются между переходами и сеансами (#5403).

  ### Исправления

  * Исправлена передача инструментов\: пустые значения `arguments` сохраняют ожидаемый блок `tool_use` (#5543).
  * Исправлено отображение и обновление селектора моделей CC Switch (#5515).
  * Исправлены обрезка и переполнение списков, таблиц, деталей журналов и iframe (#5510, #5536, #5533, #5545).

  ### Улучшения

  * Улучшены кнопки, значки способов оплаты и сведения о минимальном пополнении.
  * Улучшены описания подписок, переполнение кошелька и группы понижения тарифа.
  * Улучшены настройки, вводное руководство панели, кошелек, профиль и статистические карточки.

  ### Несовместимые изменения

  * Конечные точки вариантов и каталога подписок используют `GET`; интеграциям может потребоваться изменить метод запроса.
  * Из фильтров рейтинга удален период «Все».

  ***

  ### Изменения

  * fix(web)\: предотвращение переполнения текста и значков ячеек — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/5510](https\://github.com/QuantumNous/new-api/pull/5510)
  * fix(keys)\: обновление вариантов формы ключа API — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/5512](https\://github.com/QuantumNous/new-api/pull/5512)
  * fix\: исправление селектора моделей CC Switch — @seefs001, [https\://github.com/QuantumNous/new-api/pull/5515](https\://github.com/QuantumNous/new-api/pull/5515)
  * fix(data-table)\: учет выбора строк при memo-сравнении — @RedwindA, [https\://github.com/QuantumNous/new-api/pull/5524](https\://github.com/QuantumNous/new-api/pull/5524)
  * fix(channels)\: обновление состояния теста канала — @yyhhyyyyyy, [https\://github.com/QuantumNous/new-api/pull/5517](https\://github.com/QuantumNous/new-api/pull/5517)
  * fix\: восстановление высоты пользовательского iframe — @seefs001, [https\://github.com/QuantumNous/new-api/pull/5545](https\://github.com/QuantumNous/new-api/pull/5545)
  * fix(web)\: предотвращение обрезки низа деталей журналов — @yyhhyyyyyy, [https\://github.com/QuantumNous/new-api/pull/5533](https\://github.com/QuantumNous/new-api/pull/5533)
  * fix\: управление контекстом AWS AK/SK — @seefs001, [https\://github.com/QuantumNous/new-api/pull/5547](https\://github.com/QuantumNous/new-api/pull/5547)
  * test\: очистка тестов бэкенда с обходом проверки результата — @seefs001, [https\://github.com/QuantumNous/new-api/pull/5563](https\://github.com/QuantumNous/new-api/pull/5563)
  * fix\: сохранение блока tool\_use при пустых arguments — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/5543](https\://github.com/QuantumNous/new-api/pull/5543)
  * fix\: полное пакетное тестирование моделей канала — @yyhhyyyyyy, [https\://github.com/QuantumNous/new-api/pull/5532](https\://github.com/QuantumNous/new-api/pull/5532)
  * feat\: запоминание размера страницы таблицы между переходами и сеансами (#5377) — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/5403](https\://github.com/QuantumNous/new-api/pull/5403)
  * fix(data-table)\: предотвращение обрезки компонентов ячеек — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/5536](https\://github.com/QuantumNous/new-api/pull/5536)
  * fix(oauth)\: удаление привязок при окончательном удалении пользователя — @seefs001, [https\://github.com/QuantumNous/new-api/pull/5582](https\://github.com/QuantumNous/new-api/pull/5582)
  * feat\: расширенные пользовательские каналы — @seefs001, [https\://github.com/QuantumNous/new-api/pull/5590](https\://github.com/QuantumNous/new-api/pull/5590)

  **Полный список изменений**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.11...v1.0.0-rc.12](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.11...v1.0.0-rc.12)

  **Загрузки**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.12](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/new-api-arm64-v1.0.0-rc.12) (122.9 MB)
  * [new-api-macos-v1.0.0-rc.12](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/new-api-macos-v1.0.0-rc.12) (142.1 MB)
  * [new-api-v1.0.0-rc.12](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/new-api-v1.0.0-rc.12) (125.3 MB)
  * [new-api-v1.0.0-rc.12.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/new-api-v1.0.0-rc.12.exe) (127.0 MB)
  * [Исходный код (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.12.zip)
  * [Исходный код (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.12.tar.gz)
</Callout>

***

## v1.0.0-rc.11

<Callout type="note" title="Стабильный выпуск · Опубликован 2026-06-13 16:15:40 (время Китая)">
  Главное\: поддержка Claude Opus 4.8 и OpenAI Images, улучшенные редактор цен и большие таблицы. Исправлены интерфейс, квоты, совместимость ретранслятора и отдельные провайдеры.

  ### Новые возможности

  * Добавлена Claude Opus 4.8 (#5177).
  * Добавлено управление очисткой привязки при отключении канала (#5306).
  * Добавлен переключатель оплаты подписки балансом.
  * На странице профиля показывается ID пользователя (#5317).
  * OpenAI Images поддерживает потоковую ретрансляцию и редактирование (#4608).

  ### Исправления

  * После отправки формы фокус переходит к первой ошибке проверки (#5163).
  * Пользовательское имя CC Switch больше не сбрасывается при потере фокуса (#5170).
  * Синхронизированы пользовательские значки моделей в ценах (#5224).
  * Расширенные ошибки канала показываются без раскрытия несвязанных настроек (#5239).
  * Конвертация валюты обновляет единицу и сумму квоты/баланса (#5296).
  * Исправлена работа удаленных изображений Dify в файловых запросах (#5134).
  * Исправлен выбор модели при получении видеозадачи (#5133).
  * Улучшена передача GLM в Anthropic-совместимом формате (#5307).
  * Адаптация OpenAI o-серии ограничена поддерживаемыми моделями (#5293).
  * Множественный выбор учитывает активную тему (#5328).
  * Исправлена нормализация temperature Kimi K2.6 (#5390).
  * Добавлен фильтр статуса удаленных пользователей (#5464).
  * Настройки развертывания загружаются только на соответствующей странице (#5466).

  ### Улучшения

  * Ускорены журналы администратора и пакетные обновления (#5116).
  * Улучшены редактор цен, черновики, JSON и шаги до шести знаков после запятой (#5275).
  * Поиск каналов использует debounce и корректно работает с вводом IME (#5393).
  * Улучшены отрисовка таблиц, закрепленные колонки, макет и значки (#5405).
  * Улучшены размеры диалогов и нижние панели (#5346).
  * Упрощен вводный текст публичной главной страницы (#5339).

  ***

  ### Изменения

  * fix(web)\: фокус на ошибке проверки формы — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/5163](https\://github.com/QuantumNous/new-api/pull/5163)
  * feat(keys/cc-switch-dialog)\: имя CC Switch больше не сбрасывается при потере фокуса — @GnezIew, [https\://github.com/QuantumNous/new-api/pull/5170](https\://github.com/QuantumNous/new-api/pull/5170)
  * fix(model)\: порядок колонок idx\_created\_at\_id — (created\_at, id) — @realRoc, [https\://github.com/QuantumNous/new-api/pull/5191](https\://github.com/QuantumNous/new-api/pull/5191)
  * perf\: сортировка журналов администратора по created\_at для составного индекса — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/5116](https\://github.com/QuantumNous/new-api/pull/5116)
  * chore(deps)\: обновление axios с 1.15.2 до 1.16.0 в /web/classic — @dependabot\[bot], [https\://github.com/QuantumNous/new-api/pull/5185](https\://github.com/QuantumNous/new-api/pull/5185)
  * feat\: поддержка claude-opus-4-8 — @hjxwz123, [https\://github.com/QuantumNous/new-api/pull/5177](https\://github.com/QuantumNous/new-api/pull/5177)
  * fix(pricing)\: синхронизация пользовательских значков моделей — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/5224](https\://github.com/QuantumNous/new-api/pull/5224)
  * chore(web)\: централизация общих версий зависимостей фронтенда — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/5227](https\://github.com/QuantumNous/new-api/pull/5227)
  * feat(web)\: разработка и сборка классического интерфейса через Rsbuild — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/5232](https\://github.com/QuantumNous/new-api/pull/5232)
  * fix(channels)\: показ расширенных ошибок проверки — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/5239](https\://github.com/QuantumNous/new-api/pull/5239)
  * docs\: уточнение шаблонов задач — @seefs001, [https\://github.com/QuantumNous/new-api/pull/5271](https\://github.com/QuantumNous/new-api/pull/5271)
  * fix\: при смене единицы баланса меняется и значение — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/5296](https\://github.com/QuantumNous/new-api/pull/5296)
  * fix(dify)\: инициализация указателя файла до назначения удаленного изображения — @Pluviobyte, [https\://github.com/QuantumNous/new-api/pull/5134](https\://github.com/QuantumNous/new-api/pull/5134)
  * fix(distributor)\: выбор модели для GET /v1/video/generations/\:task\_id — @Pluviobyte, [https\://github.com/QuantumNous/new-api/pull/5133](https\://github.com/QuantumNous/new-api/pull/5133)
  * fix\: тайм-аут простаивающего соединения ретранслятора — @seefs001, [https\://github.com/QuantumNous/new-api/pull/5309](https\://github.com/QuantumNous/new-api/pull/5309)
  * feat\: настройка сброса привязки к каналу после отключения — @GuangYiDing, [https\://github.com/QuantumNous/new-api/pull/5306](https\://github.com/QuantumNous/new-api/pull/5306)
  * fix(relay)\: совместимость GLM с Anthropic без chunked encoding — @Chen011214, [https\://github.com/QuantumNous/new-api/pull/5307](https\://github.com/QuantumNous/new-api/pull/5307)
  * fix\: ограничение тела анонимного запроса — @seefs001, [https\://github.com/QuantumNous/new-api/pull/5244](https\://github.com/QuantumNous/new-api/pull/5244)
  * fix(i18n)\: уточнение текста адаптера рассуждений — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/5242](https\://github.com/QuantumNous/new-api/pull/5242)
  * fix\: сужена область адаптации моделей OpenAI o — @USER-HFC, [https\://github.com/QuantumNous/new-api/pull/5293](https\://github.com/QuantumNous/new-api/pull/5293)
  * fix\: повторное использование буфера сканера потока в каналах — @xujiantop-crypto, [https\://github.com/QuantumNous/new-api/pull/5225](https\://github.com/QuantumNous/new-api/pull/5225)
  * feat(web)\: ID пользователя в профиле — @P2K0, [https\://github.com/QuantumNous/new-api/pull/5317](https\://github.com/QuantumNous/new-api/pull/5317)
  * perf(model-pricing)\: удобство редактора цен — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/5275](https\://github.com/QuantumNous/new-api/pull/5275)
  * perf(web)\: упрощение вводного текста публичной страницы — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/5339](https\://github.com/QuantumNous/new-api/pull/5339)
  * perf(web)\: макет и размеры диалогов — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/5346](https\://github.com/QuantumNous/new-api/pull/5346)
  * fix\: тема всплывающего множественного выбора — @yyhhyyyyyy, [https\://github.com/QuantumNous/new-api/pull/5328](https\://github.com/QuantumNous/new-api/pull/5328)
  * fix\: выравнивание мобильного значка стоимости журнала — @yyhhyyyyyy, [https\://github.com/QuantumNous/new-api/pull/5161](https\://github.com/QuantumNous/new-api/pull/5161)
  * fix\: шаг цены до шести знаков после запятой — @yyhhyyyyyy, [https\://github.com/QuantumNous/new-api/pull/5332](https\://github.com/QuantumNous/new-api/pull/5332)
  * fix(openai)\: потоковая ретрансляция и редактирование Images API — @gaoren002, `#4608`
  * perf(web)\: debounce поиска каналов и ожидание окончания ввода IME — @QAbot-zh, [https\://github.com/QuantumNous/new-api/pull/5393](https\://github.com/QuantumNous/new-api/pull/5393)
  * fix\: нормализация temperature kimi k2.6 — @bensonfx, [https\://github.com/QuantumNous/new-api/pull/5390](https\://github.com/QuantumNous/new-api/pull/5390)
  * perf(web)\: отрисовка таблиц и закрепленные колонки — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/5405](https\://github.com/QuantumNous/new-api/pull/5405)
  * perf(data-table)\: макет таблиц и значки — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/5460](https\://github.com/QuantumNous/new-api/pull/5460)
  * feat(audit)\: локализованные журналы безопасности — @Calcium-Ion, [https\://github.com/QuantumNous/new-api/pull/5462](https\://github.com/QuantumNous/new-api/pull/5462)
  * chore\: обновление канала Codex — @seefs001, [https\://github.com/QuantumNous/new-api/pull/5461](https\://github.com/QuantumNous/new-api/pull/5461)
  * fix\: фильтр удаленных пользователей — @seefs001, [https\://github.com/QuantumNous/new-api/pull/5464](https\://github.com/QuantumNous/new-api/pull/5464)
  * fix\: настройки развертывания только на его странице — @seefs001, [https\://github.com/QuantumNous/new-api/pull/5466](https\://github.com/QuantumNous/new-api/pull/5466)

  ### Новые участники

  * @GnezIew впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/5170](https\://github.com/QuantumNous/new-api/pull/5170)
  * @realRoc впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/5191](https\://github.com/QuantumNous/new-api/pull/5191)
  * @hjxwz123 впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/5177](https\://github.com/QuantumNous/new-api/pull/5177)
  * @Pluviobyte впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/5134](https\://github.com/QuantumNous/new-api/pull/5134)
  * @GuangYiDing впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/5306](https\://github.com/QuantumNous/new-api/pull/5306)
  * @Chen011214 впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/5307](https\://github.com/QuantumNous/new-api/pull/5307)
  * @USER-HFC впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/5293](https\://github.com/QuantumNous/new-api/pull/5293)
  * @xujiantop-crypto впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/5225](https\://github.com/QuantumNous/new-api/pull/5225)
  * @P2K0 впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/5317](https\://github.com/QuantumNous/new-api/pull/5317)
  * @bensonfx впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/5390](https\://github.com/QuantumNous/new-api/pull/5390)

  **Полный список изменений**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.10...v1.0.0-rc.11](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.10...v1.0.0-rc.11)

  **Загрузки**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.11](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/new-api-arm64-v1.0.0-rc.11) (84.8 MB)
  * [new-api-macos-v1.0.0-rc.11](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/new-api-macos-v1.0.0-rc.11) (103.8 MB)
  * [new-api-v1.0.0-rc.11](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/new-api-v1.0.0-rc.11) (87.2 MB)
  * [new-api-v1.0.0-rc.11.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/new-api-v1.0.0-rc.11.exe) (88.9 MB)
  * [Исходный код (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.11.zip)
  * [Исходный код (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.11.tar.gz)
</Callout>

***

## v1.0.0-rc.10

<Callout type="note" title="Стабильный выпуск · Опубликован 2026-05-26 22:20:13 (время Китая)">
  ### Главное

  v1.0.0-rc.10 улучшает интерфейс, надежность ретранслятора и процессы администратора. Добавлены темы и оплата подписки балансом; улучшены журналы, каналы, webhook, платежи и передача инструментов провайдеров.

  ### Новые возможности

  * Добавлены темы Anthropic и Simple Large, настройка шрифта с засечками и особо крупный масштаб.
  * Подписки можно приобретать с баланса.

  ### Исправления

  * Автоматически отключенные каналы не выбираются; уведомления действий не дублируются (#4983).
  * Улучшена передача инструментов между Gemini и Claude, включая параллельные вызовы (#5095).
  * Ретрансляция изображений корректно применяет качество (#5103).
  * Фильтры журналов используют точное совпадение без явного wildcard. Большие ошибки провайдера сокращаются (#5097).
  * Повышена надежность обработки webhook (#5047).
  * Настройки Waffo сохраняются согласованно, устаревшие параметры скрыты (#5110).
  * Системные настройки правильно определяют несохраненные изменения и обрабатывают числа без недопустимых значений.

  ### Улучшения

  * Большие медиазапросы потребляют меньше памяти, повышая стабильность под нагрузкой.
  * Уплотнены и улучшены системные настройки и создание/редактирование каналов.
  * Улучшены мобильные журналы и интерфейс\: интервалы таблиц, значки, графики и темная тема.
  * Главная страница получила двухколоночный вводный блок и обновленный текст.

  ***

  ### Изменения

  * 🐛 fix(channel)\: удаление автоматически отключенных многоключевых каналов из кеша — @t0ng7u, [https\://github.com/QuantumNous/new-api/pull/4983](https\://github.com/QuantumNous/new-api/pull/4983)
  * \[Исправление] обработка webhook — @Hill-waffo, [https\://github.com/QuantumNous/new-api/pull/5047](https\://github.com/QuantumNous/new-api/pull/5047)
  * fix(payment)\: скрытие классических настроек Waffo Pancake — @seefs001, [https\://github.com/QuantumNous/new-api/pull/5085](https\://github.com/QuantumNous/new-api/pull/5085)
  * fix(relay)\: обработка качества изображения — @lanfunoe, [https\://github.com/QuantumNous/new-api/pull/5103](https\://github.com/QuantumNous/new-api/pull/5103)
  * fix\: сокращение слишком больших журналов ошибок провайдера — @seefs001, [https\://github.com/QuantumNous/new-api/pull/5083](https\://github.com/QuantumNous/new-api/pull/5083)
  * fix\: убран сдвиг fcIdx -1, исправлена коллизия параллельных инструментов — @learner-i, [https\://github.com/QuantumNous/new-api/pull/5095](https\://github.com/QuantumNous/new-api/pull/5095)
  * fix\: ошибка tool\_use при преобразовании Gemini в Claude — @nekohy, [https\://github.com/QuantumNous/new-api/pull/5041](https\://github.com/QuantumNous/new-api/pull/5041)
  * fix\: постраничный ответ поиска ключей API — @yyhhyyyyyy, [https\://github.com/QuantumNous/new-api/pull/5014](https\://github.com/QuantumNous/new-api/pull/5014)
  * fix\: устранение повторных уведомлений действий канала — @yyhhyyyyyy, [https\://github.com/QuantumNous/new-api/pull/5015](https\://github.com/QuantumNous/new-api/pull/5015)
  * fix\: единое сохранение платежных настроек Waffo — @seefs001, [https\://github.com/QuantumNous/new-api/pull/5110](https\://github.com/QuantumNous/new-api/pull/5110)
  * fix\: реальный ID пользователя в тестах каналов — @seefs001, [https\://github.com/QuantumNous/new-api/pull/5109](https\://github.com/QuantumNous/new-api/pull/5109)
  * fix\: точные фильтры журналов без явного wildcard — @yyhhyyyyyy, [https\://github.com/QuantumNous/new-api/pull/5097](https\://github.com/QuantumNous/new-api/pull/5097)

  ### Новые участники

  * @learner-i впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/5095](https\://github.com/QuantumNous/new-api/pull/5095)

  **Полный список изменений**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.8...v1.0.0-rc.10](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.8...v1.0.0-rc.10)

  **Загрузки**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/checksums-linux.txt) (180 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.10](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/new-api-arm64-v1.0.0-rc.10) (82.8 MB)
  * [new-api-v1.0.0-rc.10](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/new-api-v1.0.0-rc.10) (85.3 MB)
  * [new-api-v1.0.0-rc.10.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/new-api-v1.0.0-rc.10.exe) (86.9 MB)
  * [Исходный код (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.10.zip)
  * [Исходный код (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.10.tar.gz)
</Callout>

***

## v1.0.0-rc.8

<Callout type="note" title="Стабильный выпуск · Опубликован 2026-05-22 16:25:46 (время Китая)">
  #### Главное

  Добавлен Waffo Pancake с привязкой каталога и товаров администратора. Улучшены административный API, метаданные и цены моделей, диагностика каналов, фильтры панели и эффективность запросов.

  #### Новые возможности

  * Добавлен шлюз Waffo Pancake с привязкой каталога/товаров администратора (#4935).

  #### Исправления

  * Панель последовательно соблюдает настройки видимости (#4975).
  * Сводные метрики производительности учитывают только активные группы (#4976).
  * Унифицированы значения отображаемых цен (#4985).
  * Владелец модели определяется по активным каналам для точного каталога (#4416).
  * Исправлены маршруты ссылок стандартного интерфейса (#5016).
  * Восстановлено прежнее поведение фильтров журналов для устранения регрессии.

  #### Улучшения

  * Тесты каналов показывают более понятные сведения о сбоях (#4988).
  * Снижены накладные расходы обработки запросов под нагрузкой (#5009).

  ***

  ### Изменения

  * fix\: аудит переопределения чувствительных полей сообщений — @seefs001, [https\://github.com/QuantumNous/new-api/pull/4974](https\://github.com/QuantumNous/new-api/pull/4974)
  * fix\: соблюдение настроек видимости панели — @seefs001, [https\://github.com/QuantumNous/new-api/pull/4975](https\://github.com/QuantumNous/new-api/pull/4975)
  * fix\: метрики только активных групп — @seefs001, [https\://github.com/QuantumNous/new-api/pull/4976](https\://github.com/QuantumNous/new-api/pull/4976)
  * fix\: удобство диагностики ошибок теста канала — @yyhhyyyyyy, [https\://github.com/QuantumNous/new-api/pull/4988](https\://github.com/QuantumNous/new-api/pull/4988)
  * fix\: нормализация отображения цен моделей — @yyhhyyyyyy, [https\://github.com/QuantumNous/new-api/pull/4985](https\://github.com/QuantumNous/new-api/pull/4985)
  * fix\: определение owned\_by по активным каналам — @yyhhyyyyyy, [https\://github.com/QuantumNous/new-api/pull/4416](https\://github.com/QuantumNous/new-api/pull/4416)
  * perf\: извлечение метаданных запроса и фильтрация отключенных полей — @seefs001, [https\://github.com/QuantumNous/new-api/pull/5009](https\://github.com/QuantumNous/new-api/pull/5009)
  * fix\: исправление жестко заданных ссылок стандартного интерфейса — @yyhhyyyyyy, [https\://github.com/QuantumNous/new-api/pull/5016](https\://github.com/QuantumNous/new-api/pull/5016)
  * Исправлена отсутствующая проверка Turnstile при регистрации в новом фронтенде — @JunXiaoRuo, [https\://github.com/QuantumNous/new-api/pull/5011](https\://github.com/QuantumNous/new-api/pull/5011)
  * \[Запрос функции] Полная интеграция Waffo Pancake с подписками и привязкой каталога администратора — @Hill-waffo, [https\://github.com/QuantumNous/new-api/pull/4935](https\://github.com/QuantumNous/new-api/pull/4935)
  * fix\: соблюдение требований подписок Waffo и обновление ID товара — @seefs001, [https\://github.com/QuantumNous/new-api/pull/5038](https\://github.com/QuantumNous/new-api/pull/5038)

  ### Новые участники

  * @JunXiaoRuo впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/5011](https\://github.com/QuantumNous/new-api/pull/5011)
  * @Hill-waffo впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/4935](https\://github.com/QuantumNous/new-api/pull/4935)

  **Полный список изменений**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.7...v1.0.0-rc.8](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.7...v1.0.0-rc.8)

  **Загрузки**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.8](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/new-api-arm64-v1.0.0-rc.8) (82.4 MB)
  * [new-api-v1.0.0-rc.8](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/new-api-v1.0.0-rc.8) (84.8 MB)
  * [new-api-v1.0.0-rc.8.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/new-api-v1.0.0-rc.8.exe) (86.5 MB)
  * [Исходный код (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.8.zip)
  * [Исходный код (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.8.tar.gz)
</Callout>

***

## v1.0.0-rc.7

<Callout type="note" title="Стабильный выпуск · Опубликован 2026-05-19 16:54:08 (время Китая)">
  #### Новые возможности

  * Добавлен источник ключа `request_header` (#4903).

  #### Исправления

  * Пакетно исправлены проблемы стандартного интерфейса (#4880, #4893, #4817, #4877, #4898, #4876).
  * Примечание канала можно очистить (#4886).
  * Исправлены фильтры журналов потребления (#4883).
  * Исправлена проверка безлимитной квоты ключа API (#4881).
  * Для публичной навигации применяется контроль доступа (#4889).
  * Фильтры групп правильно применяются к списку каналов (#4847, #4885).
  * Устранена неоднозначность имен колонок при upsert `PerfMetric` (#4684).
  * В стандартную тему добавлены отсутствующие заглушки аналитики (#4928).
  * Правильный тип кнопки исправляет отправку формы забытого пароля (#4910).
  * Унифицированы вкладки сведений модели (#4938).
  * Исправлены создание и удаление пользователей в панели (#4818).
  * Ссылка регистрации на входе учитывает настройки регистрации (#4871).
  * Обновлены подписи пагинации ModelCardGrid (#4675).
  * Локализовано подтверждение сброса пароля (#4769).
  * Выбранный вариант пополнения виден в темной теме (#4897).
  * Исправлен цвет точки API из-за несоответствия семантического токена (#4824).
  * Устранено молчаливое несохранение API при неверном цвете (#4823).
  * В данных регистрации используется правильное имя `aff_code` (#4965).
  * Ширина фасетного фильтра таблиц адаптивна (#4966).
  * Устранены устаревшие связи формы при отправке ключей (#4967).

  #### Улучшения

  * Отложенное форматирование debug-журналов повышает производительность (#4929).

  ***

  ### Изменения

  * fix\: очистка примечания канала — @yyhhyyyyyy, [https\://github.com/QuantumNous/new-api/pull/4886](https\://github.com/QuantumNous/new-api/pull/4886)
  * fix\: фильтры журналов потребления — @yyhhyyyyyy, [https\://github.com/QuantumNous/new-api/pull/4883](https\://github.com/QuantumNous/new-api/pull/4883)
  * fix(web)\: проверка безлимитной квоты ключей API — @yyhhyyyyyy, [https\://github.com/QuantumNous/new-api/pull/4881](https\://github.com/QuantumNous/new-api/pull/4881)
  * fix\: контроль доступа публичной верхней навигации — @yyhhyyyyyy, [https\://github.com/QuantumNous/new-api/pull/4889](https\://github.com/QuantumNous/new-api/pull/4889)
  * fix\: GetAllChannels учитывает фильтр группы — @draftgo, [https\://github.com/QuantumNous/new-api/pull/4847](https\://github.com/QuantumNous/new-api/pull/4847)
  * fix\: квалификация колонок PerfMetric upsert для PostgreSQL — @SAY-5, [https\://github.com/QuantumNous/new-api/pull/4684](https\://github.com/QuantumNous/new-api/pull/4684)
  * fix\: фильтр группы в списке каналов — @yyhhyyyyyy, [https\://github.com/QuantumNous/new-api/pull/4885](https\://github.com/QuantumNous/new-api/pull/4885)
  * feat\: источник ключа request\_header — @seefs001, [https\://github.com/QuantumNous/new-api/pull/4903](https\://github.com/QuantumNous/new-api/pull/4903)
  * fix\: язык и тексты нового интерфейса — @QuentinHsu, [https\://github.com/QuantumNous/new-api/pull/4876](https\://github.com/QuantumNous/new-api/pull/4876)
  * fix\: заглушки umami и ga4 в index.html стандартной темы — @NitroRCr, [https\://github.com/QuantumNous/new-api/pull/4928](https\://github.com/QuantumNous/new-api/pull/4928)
  * perf\: отказ от немедленного форматирования debug-журналов — @seefs001, [https\://github.com/QuantumNous/new-api/pull/4929](https\://github.com/QuantumNous/new-api/pull/4929)
  * fix\: type="submit" кнопки забытого пароля — @lihan3238, [https\://github.com/QuantumNous/new-api/pull/4910](https\://github.com/QuantumNous/new-api/pull/4910)
  * fix(web)\: макет вкладок сведений модели — @yyhhyyyyyy, [https\://github.com/QuantumNous/new-api/pull/4938](https\://github.com/QuantumNous/new-api/pull/4938)
  * fix(user)\: создание и удаление пользователей панели — @bugmaker2, [https\://github.com/QuantumNous/new-api/pull/4818](https\://github.com/QuantumNous/new-api/pull/4818)
  * fix(auth)\: register\_enabled в /api/status и управление ссылкой регистрации — @Gnonymous, [https\://github.com/QuantumNous/new-api/pull/4871](https\://github.com/QuantumNous/new-api/pull/4871)
  * fix(web/default)\: подписи пагинации ModelCardGrid — @ellisfan, [https\://github.com/QuantumNous/new-api/pull/4675](https\://github.com/QuantumNous/new-api/pull/4675)
  * fix(auth)\: локализация подтверждения сброса пароля — @neow021, [https\://github.com/QuantumNous/new-api/pull/4769](https\://github.com/QuantumNous/new-api/pull/4769)
  * fix(web/default/wallet)\: выбранное пополнение в темной теме — @xinnyu, [https\://github.com/QuantumNous/new-api/pull/4897](https\://github.com/QuantumNous/new-api/pull/4897)
  * fix(web/default)\: правильный семантический цвет точки API — @Micah-Zheng, [https\://github.com/QuantumNous/new-api/pull/4824](https\://github.com/QuantumNous/new-api/pull/4824)
  * fix(web/default)\: ошибки сохранения API при неверном цвете или непроверенном результате — @Micah-Zheng, [https\://github.com/QuantumNous/new-api/pull/4823](https\://github.com/QuantumNous/new-api/pull/4823)
  * fix(auth)\: поле aff\_code в данных регистрации (#4945) — @Calcium-Ion, [https\://github.com/QuantumNous/new-api/pull/4965](https\://github.com/QuantumNous/new-api/pull/4965)
  * fix(data-table)\: адаптивная ширина фасетного фильтра (#4905) — @Calcium-Ion, [https\://github.com/QuantumNous/new-api/pull/4966](https\://github.com/QuantumNous/new-api/pull/4966)
  * fix(keys)\: прямой вызов обработчика отправки без устаревшей связи (#4858) — @Calcium-Ion, [https\://github.com/QuantumNous/new-api/pull/4967](https\://github.com/QuantumNous/new-api/pull/4967)

  ### Новые участники

  * @draftgo впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/4847](https\://github.com/QuantumNous/new-api/pull/4847)
  * @SAY-5 впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/4684](https\://github.com/QuantumNous/new-api/pull/4684)
  * @bugmaker2 впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/4818](https\://github.com/QuantumNous/new-api/pull/4818)
  * @Gnonymous впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/4871](https\://github.com/QuantumNous/new-api/pull/4871)
  * @ellisfan впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/4675](https\://github.com/QuantumNous/new-api/pull/4675)
  * @neow021 впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/4769](https\://github.com/QuantumNous/new-api/pull/4769)
  * @xinnyu впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/4897](https\://github.com/QuantumNous/new-api/pull/4897)

  **Полный список изменений**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.6...v1.0.0-rc.7](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.6...v1.0.0-rc.7)

  **Загрузки**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.7](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/new-api-arm64-v1.0.0-rc.7) (82.3 MB)
  * [new-api-v1.0.0-rc.7](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/new-api-v1.0.0-rc.7) (84.6 MB)
  * [new-api-v1.0.0-rc.7.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/new-api-v1.0.0-rc.7.exe) (86.3 MB)
  * [Исходный код (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.7.zip)
  * [Исходный код (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.7.tar.gz)
</Callout>

***

## v1.0.0-rc.6

<Callout type="note" title="Стабильный выпуск · Опубликован 2026-05-13 22:29:13 (время Китая)">
  ### Главное

  Улучшена наблюдаемость\: ID запросов провайдера сохраняются в журнале; платные функции требуют подтверждения соблюдения требований. Если таблица `logs` велика, заранее добавьте колонку `upstream_request_id` и индекс через online DDL до обновления, чтобы избежать длительной миграции.

  ### Новые возможности

  * В журнал добавлены ID запросов провайдера для трассировки без нежелательного переопределения заголовков ответа.
  * До использования платных функций добавлено подтверждение соблюдения требований.

  ### Исправления

  * Фокус комбобокса канала больше не скрывает подходящие варианты (#4829).

  ### Прочее

  * Уведомление об обновлении\: таблица `logs` получила колонку `upstream_request_id` и индекс. В больших системах предварительно выполните подходящий online DDL ниже, избегая длительной или блокирующей автоматической миграции.

  MySQL / InnoDB\:

  ```sql
  -- 1. Add the column using online DDL.
  ALTER TABLE logs
    ADD COLUMN upstream_request_id VARCHAR(128) NOT NULL DEFAULT '',
    ALGORITHM=INPLACE, LOCK=NONE;

  -- 2. Add the index using online DDL.
  ALTER TABLE logs
    ADD INDEX idx_logs_upstream_request_id (upstream_request_id),
    ALGORITHM=INPLACE, LOCK=NONE;
  ```

  PostgreSQL 11+\:

  ```sql
  -- 1. Add the column without rewriting the table on PG 11+.
  ALTER TABLE logs
    ADD COLUMN IF NOT EXISTS upstream_request_id VARCHAR(128) NOT NULL DEFAULT '';

  -- 2. Add the index concurrently to avoid blocking reads and writes.
  CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_logs_upstream_request_id
    ON logs (upstream_request_id);
  ```

  ***

  ### Изменения

  * chore(deps)\: обновление axios с 1.15.0 до 1.15.2 в /web/classic — @dependabot\[bot], [https\://github.com/QuantumNous/new-api/pull/4634](https\://github.com/QuantumNous/new-api/pull/4634)
  * chore(deps-dev)\: обновление ip-address с 10.1.0 до 10.2.0 в /electron — @dependabot\[bot], [https\://github.com/QuantumNous/new-api/pull/4811](https\://github.com/QuantumNous/new-api/pull/4811)
  * Исправлен неполный список каналов — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/4829](https\://github.com/QuantumNous/new-api/pull/4829)

  **Полный список изменений**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.5...v1.0.0-rc.6](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.5...v1.0.0-rc.6)

  **Загрузки**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.6](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/new-api-arm64-v1.0.0-rc.6) (82.3 MB)
  * [new-api-v1.0.0-rc.6](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/new-api-v1.0.0-rc.6) (84.6 MB)
  * [new-api-v1.0.0-rc.6.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/new-api-v1.0.0-rc.6.exe) (86.3 MB)
  * [Исходный код (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.6.zip)
  * [Исходный код (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.6.tar.gz)
</Callout>

***

## v1.0.0-rc.5

<Callout type="note" title="Стабильный выпуск · Опубликован 2026-05-12 16:53:57 (время Китая)">
  ### Главное

  Панель обновлена\: встроены метрики моделей и более ясный обзор здоровья. Добавлены deeplink DeepChat; исправлены интерфейс, кошелек, Playground и коэффициенты.

  ### Новые возможности

  * Новый обзор панели включает метрики моделей и понятную панель здоровья.
  * Deeplink DeepChat открывает поддерживаемые ссылки чата прямо в клиенте (#4668).

  ### Исправления

  * Доступность платежного шлюза определяется правильными настройками пополнения (#4599).
  * Отображение коэффициентов учитывает настроенное соотношение групп (#4772).
  * Пункты выпадающего меню корректно вызывают обработчик выбора (#4787).
  * Playground обрабатывает старый классический формат сообщений без сбоя (#4650).
  * Устранены регрессии v1\: пустые описания и проблемы макета (#4802).

  ### Улучшения

  * Интерфейс и графики следуют общей теме цветов, элементов и скруглений.
  * Docker-образы включают лицензии проекта и третьих сторон (#4739).

  ***

  ### Изменения

  * feat\: поддержка deeplink DeepChat — @yyhhyyyyyy, [https\://github.com/QuantumNous/new-api/pull/4668](https\://github.com/QuantumNous/new-api/pull/4668)
  * fix\: THIRD-PARTY-LICENSES.md не исключается .dockerignore — @yeying-xingchen, [https\://github.com/QuantumNous/new-api/pull/4739](https\://github.com/QuantumNous/new-api/pull/4739)
  * fix(wallet)\: флаги шлюза из topupInfo вместо status — @ImogeneOctaviap794, [https\://github.com/QuantumNous/new-api/pull/4599](https\://github.com/QuantumNous/new-api/pull/4599)
  * fix(web/default)\: getUserGroups учитывает GroupGroupRatio — @Micah-Zheng, [https\://github.com/QuantumNous/new-api/pull/4772](https\://github.com/QuantumNous/new-api/pull/4772)
  * fix(default)\: поддержка onSelect DropdownMenuItem — @lihan3238, [https\://github.com/QuantumNous/new-api/pull/4787](https\://github.com/QuantumNous/new-api/pull/4787)
  * fix(web/default)\: обработка старых классических сообщений Playground — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/4650](https\://github.com/QuantumNous/new-api/pull/4650)
  * fix\: устранение проблем стандартного интерфейса — @Calcium-Ion, [https\://github.com/QuantumNous/new-api/pull/4802](https\://github.com/QuantumNous/new-api/pull/4802)

  ### Новые участники

  * @yeying-xingchen впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/4739](https\://github.com/QuantumNous/new-api/pull/4739)
  * @lihan3238 впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/4787](https\://github.com/QuantumNous/new-api/pull/4787)

  **Полный список изменений**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.4...v1.0.0-rc.5](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.4...v1.0.0-rc.5)

  **Загрузки**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.5](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/new-api-arm64-v1.0.0-rc.5) (82.1 MB)
  * [new-api-v1.0.0-rc.5](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/new-api-v1.0.0-rc.5) (84.5 MB)
  * [new-api-v1.0.0-rc.5.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/new-api-v1.0.0-rc.5.exe) (86.2 MB)
  * [Исходный код (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.5.zip)
  * [Исходный код (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.5.tar.gz)
</Callout>

***

## v1.0.0-rc.4

<Callout type="note" title="Стабильный выпуск · Опубликован 2026-05-06 22:25:59 (время Китая)">
  ### Главное

  Редактирование OpenAI надежнее\: при передаче сохраняются референсы и метаданные, не теряется контекст (#4646). Добавлены значки производительности и исправлены цены и меню.

  ### Новые возможности

  * В список моделей добавлены значки производительности для сравнения.

  ### Исправления

  * Ретрансляция OpenAI сохраняет референсы и метаданные редактирования (#4646).
  * Повышена надежность полей пополнения и тарификации.
  * После обновления компонентов исправлены отображение и выбор пунктов меню (#4655).

  ### Несовместимые изменения

  * Интеграции должны получать ссылку пополнения из API сведений пополнения, а не status.

  ### Галерея

  | Рейтинг доступности моделей                                                                                                   | Обновленные цены и настройки                                                                                                  |
  | ----------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
  | ![Иллюстрация галереи примечаний к выпуску](https\://github.com/user-attachments/assets/03e974ba-4605-4bfd-83ef-dd32a30974de) | ![Иллюстрация галереи примечаний к выпуску](https\://github.com/user-attachments/assets/db5bb31a-ef40-4914-989f-b7a6fd569a85) |

  ***

  ### Изменения

  * fix\: сохранение полей референса редактирования OpenAI — @seefs001, [https\://github.com/QuantumNous/new-api/pull/4646](https\://github.com/QuantumNous/new-api/pull/4646)
  * fix\: перевод select на API элементов Base UI — @yyhhyyyyyy, [https\://github.com/QuantumNous/new-api/pull/4655](https\://github.com/QuantumNous/new-api/pull/4655)

  **Полный список изменений**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.3...v1.0.0-rc.4](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.3...v1.0.0-rc.4)

  **Загрузки**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.4](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/new-api-arm64-v1.0.0-rc.4) (82.0 MB)
  * [new-api-v1.0.0-rc.4](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/new-api-v1.0.0-rc.4) (84.4 MB)
  * [new-api-v1.0.0-rc.4.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/new-api-v1.0.0-rc.4.exe) (86.1 MB)
  * [Исходный код (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.4.zip)
  * [Исходный код (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.4.tar.gz)
</Callout>

***

## v1.0.0-rc.3

<Callout type="note" title="Стабильный выпуск · Опубликован 2026-05-06 18:43:33 (время Китая)">
  ### Главное

  v1.0.0-rc.3 вводит рейтинг доступности и производительности моделей для сравнения надежности маршрутов и провайдеров. Обновлены цены, настройки и элементы управления таблицами.

  ### Новые возможности

  * Добавлена панель рейтинга с реальными данными доступности и производительности моделей (#4633).

  ### Улучшения

  * Стандартный интерфейс обновлен на Base UI, новые темы и удобные панели таблиц (#4633).
  * Перестроены системные настройки цен для удобного просмотра и управления.

  ### Исправления

  * Исправлена серверная сортировка таблицы каналов (#4600).
  * Исправлены платежные сведения подписок в стандартном интерфейсе.

  ### Галерея

  | Рейтинг доступности моделей                                                                                                   | Обновленные цены и настройки                                                                                                  |
  | ----------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
  | ![Иллюстрация галереи примечаний к выпуску](https\://github.com/user-attachments/assets/03e974ba-4605-4bfd-83ef-dd32a30974de) | ![Иллюстрация галереи примечаний к выпуску](https\://github.com/user-attachments/assets/db5bb31a-ef40-4914-989f-b7a6fd569a85) |

  ***

  ### Изменения

  * feat(web/default)\: обновление UI — Base UI, темы, рейтинг и панели таблиц — @Calcium-Ion, [https\://github.com/QuantumNous/new-api/pull/4633](https\://github.com/QuantumNous/new-api/pull/4633)
  * feat\: сбор метрик производительности моделей — @Calcium-Ion, [https\://github.com/QuantumNous/new-api/pull/4635](https\://github.com/QuantumNous/new-api/pull/4635)
  * fix\: серверная сортировка таблицы каналов — @yyhhyyyyyy, [https\://github.com/QuantumNous/new-api/pull/4600](https\://github.com/QuantumNous/new-api/pull/4600)

  **Полный список изменений**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.2...v1.0.0-rc.3](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.2...v1.0.0-rc.3)

  **Загрузки**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.3](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/new-api-arm64-v1.0.0-rc.3) (81.9 MB)
  * [new-api-v1.0.0-rc.3](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/new-api-v1.0.0-rc.3) (84.4 MB)
  * [new-api-v1.0.0-rc.3.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/new-api-v1.0.0-rc.3.exe) (86.1 MB)
  * [Исходный код (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.3.zip)
  * [Исходный код (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.3.tar.gz)
</Callout>

***

## v1.0.0-rc.2

<Callout type="note" title="Стабильный выпуск · Опубликован 2026-04-30 20:42:48 (время Китая)">
  ### Главное

  v1.0.0-rc.2 открывает переключение нового и классического интерфейсов для проверки процессов и быстрого возврата. Обновлены основные страницы консоли; исправлены привязка email, многоуровневые цены, группы ключей и адреса Vertex.

  ### Новые возможности

  * Добавлен переключатель нового и классического интерфейсов для постепенного перехода без потери старых процессов.

  ### Улучшения

  * Обновлены цены, панель, журналы, фильтры таблиц и аналитики, навигация и мобильный интерфейс.

  ### Исправления

  * Исправлена привязка email в новом интерфейсе (#4551).
  * Исправлен ввод чисел многоуровневых тарифов (#4536).
  * Исправлены значения и подписи многоуровневых тарифов (#4530).
  * Исправлено распределение ключей API по группам стандартной темы (#4548).
  * Пользовательские адреса Vertex учитывают префикс шлюза (#4200).

  ### Галерея

  | Обновленная страница цен                                                                                      | Элементы панели и аналитики                                                                                      |
  | ------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
  | ![Обновленная страница цен](https\://github.com/user-attachments/assets/8d403155-27ac-407d-b0ae-8815034c66a7) | ![Элементы панели и аналитики](https\://github.com/user-attachments/assets/caa73f0a-13d2-47fc-ab7d-0ffb4e7b6194) |

  ### Изменения

  * fix\: поведение групп ключей API в стандартной теме — @Micah-Zheng, [https\://github.com/QuantumNous/new-api/pull/4548](https\://github.com/QuantumNous/new-api/pull/4548)
  * bug fix\: привязка email нового фронтенда — @SHLE1, [https\://github.com/QuantumNous/new-api/pull/4551](https\://github.com/QuantumNous/new-api/pull/4551)
  * fix\: ввод чисел многоуровневых тарифов — @yyhhyyyyyy, [https\://github.com/QuantumNous/new-api/pull/4536](https\://github.com/QuantumNous/new-api/pull/4536)
  * fix(vertex)\: custom base\_url как префикс шлюза — @yyhhyyyyyy, [https\://github.com/QuantumNous/new-api/pull/4200](https\://github.com/QuantumNous/new-api/pull/4200)
  * fix(web)\: декодирование Base64 и несовпадение тегов ступенчатых цен — @wans10, [https\://github.com/QuantumNous/new-api/pull/4530](https\://github.com/QuantumNous/new-api/pull/4530)

  ### Новые участники

  * @SHLE1 впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/4551](https\://github.com/QuantumNous/new-api/pull/4551)

  **Полный список изменений**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.1...v1.0.0-rc.2](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.1...v1.0.0-rc.2)

  **Загрузки**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/new-api-arm64-v1.0.0-rc.2) (76.5 MB)
  * [new-api-v1.0.0-rc.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/new-api-v1.0.0-rc.2) (78.9 MB)
  * [new-api-v1.0.0-rc.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/new-api-v1.0.0-rc.2.exe) (80.6 MB)
  * [Исходный код (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.2.zip)
  * [Исходный код (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.2.tar.gz)
</Callout>

***

## v1.0.0-rc.1

<Callout type="note" title="Стабильный выпуск · Опубликован 2026-04-29 20:15:01 (время Китая)">
  v1.0.0-rc.1 — первый кандидат предстоящего выпуска 1.0. Главное изменение — полностью новый фронтенд v1 для более удобного, быстрого и функционального администрирования.

  RC обновляет навигацию, настройки, аналитику и журналы, упрощая управление перед финальным выпуском v1.

  ![Иллюстрация примечаний к выпуску v1.0.0-rc.1](https\://github.com/user-attachments/assets/f3f8ed32-e0c5-4cfb-94a3-da0f357b62ab)

  ### Новые возможности

  * Представлен новый фронтенд v1 с современным макетом, визуальным редактором переопределений канала, быстрым доступом к настройкам и темам (#4265).

  ### Улучшения

  * Панели и графики получили ясную аналитику моделей, сортировку и подсказки.
  * Журналы показывают типы, имена и аватары пользователей в более ясных таблицах.
  * Унифицированы общие макеты, таблицы и формы стандартного интерфейса.

  ### Исправления

  * Темы, загруженные из базы, правильно применяются во время работы (#4518).
  * При пересылке сохраняются пустые поля рассуждений (#4520).
  * Формы правильно показывают обязательные поля (#4533).

  ***

  ### Изменения

  * 🚀 feat\: запуск v1.0 — новый фронтенд с нуля — @t0ng7u, [https\://github.com/QuantumNous/new-api/pull/4265](https\://github.com/QuantumNous/new-api/pull/4265)
  * fix\: сохранение пустых Message.ReasoningContent/Reasoning при пересылке — @heimoshuiyu, [https\://github.com/QuantumNous/new-api/pull/4520](https\://github.com/QuantumNous/new-api/pull/4520)
  * fix\: применение темы, загруженной из базы — @Micah-Zheng, [https\://github.com/QuantumNous/new-api/pull/4518](https\://github.com/QuantumNous/new-api/pull/4518)

  ### Новые участники

  * @Micah-Zheng впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/4518](https\://github.com/QuantumNous/new-api/pull/4518)

  **Полный список изменений**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-alpha.1...v1.0.0-rc.1](https\://github.com/QuantumNous/new-api/compare/v1.0.0-alpha.1...v1.0.0-rc.1)

  **Загрузки**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.1](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/new-api-arm64-v1.0.0-rc.1) (76.4 MB)
  * [new-api-v1.0.0-rc.1](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/new-api-v1.0.0-rc.1) (78.8 MB)
  * [new-api-v1.0.0-rc.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/new-api-v1.0.0-rc.1.exe) (80.5 MB)
  * [Исходный код (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.1.zip)
  * [Исходный код (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.1.tar.gz)
</Callout>

***

## v1.0.0-alpha.1 — выпуск, определяющий границы лицензии

<Callout type="note" title="Предварительный выпуск · Опубликован 2026-04-28 14:26:06 (время Китая)">
  **Полный список изменений**\: [https\://github.com/QuantumNous/new-api/compare/v0.13.2...v1.0.0-alpha.1](https\://github.com/QuantumNous/new-api/compare/v0.13.2...v1.0.0-alpha.1)

  **Загрузки**

  * [Исходный код (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-alpha.1.zip)
  * [Исходный код (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-alpha.1.tar.gz)
</Callout>

***

## v0.13.2

<Callout type="note" title="Стабильный выпуск · Опубликован 2026-04-27 22:11:42 (время Китая)">
  ### Новые возможности

  * Синхронизация точнее обнаруживает модели, обновляет цены из API провайдера, показывает удаленные модели и сохраняет цены при задержках (#4452).
  * В учетных записях появились время создания и последнего входа для аудита (#4450).
  * Добавлено настраиваемое сопоставление моделей нативного Ali Messages API (#4468).

  ### Исправления

  * Аргументы инструментов принимаются как необработанные объекты JSON для совместимости (#4469).
  * Повышена надежность сохранения настроек с объектами JSON.

  ### Улучшения

  * Сообщения повторов ясно объясняют пропуск канала из-за отключенной привязки (#4453).

  ***

  ### Изменения

  * fix(channel)\: загрузка сопоставления моделей при проверке провайдера — @seefs001, [https\://github.com/QuantumNous/new-api/pull/4437](https\://github.com/QuantumNous/new-api/pull/4437)
  * feat\: синхронизация цен через API провайдера — @seefs001, [https\://github.com/QuantumNous/new-api/pull/4452](https\://github.com/QuantumNous/new-api/pull/4452)
  * fix\: сообщение повтора при отключенной привязке — @seefs001, [https\://github.com/QuantumNous/new-api/pull/4453](https\://github.com/QuantumNous/new-api/pull/4453)
  * feat\: сопоставление моделей нативных сообщений Ali — @seefs001, [https\://github.com/QuantumNous/new-api/pull/4468](https\://github.com/QuantumNous/new-api/pull/4468)
  * fix\: аргументы инструментов как raw JSON — @seefs001, [https\://github.com/QuantumNous/new-api/pull/4469](https\://github.com/QuantumNous/new-api/pull/4469)
  * feat\: удаленные модели в окне получения моделей — @seefs001, [https\://github.com/QuantumNous/new-api/pull/4470](https\://github.com/QuantumNous/new-api/pull/4470)
  * Добавлено время создания и последнего входа пользователя — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/4450](https\://github.com/QuantumNous/new-api/pull/4450)

  **Полный список изменений**\: [https\://github.com/QuantumNous/new-api/compare/v0.13.1-patch.1...v0.13.2](https\://github.com/QuantumNous/new-api/compare/v0.13.1-patch.1...v0.13.2)

  **Загрузки**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/checksums-linux.txt) (170 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/checksums-macos.txt) (88 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/checksums-windows.txt) (86 B)
  * [New-API-App.0.13.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/New-API-App.0.13.2.exe) (106.5 MB)
  * [New-API-App.Setup.0.13.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/New-API-App.Setup.0.13.2.exe) (106.8 MB)
  * [new-api-arm64-v0.13.2](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/new-api-arm64-v0.13.2) (64.6 MB)
  * [new-api-macos-v0.13.2](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/new-api-macos-v0.13.2) (83.2 MB)
  * [new-api-v0.13.2](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/new-api-v0.13.2) (67.0 MB)
  * [new-api-v0.13.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/new-api-v0.13.2.exe) (68.6 MB)
  * [Исходный код (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.2.zip)
  * [Исходный код (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.2.tar.gz)
</Callout>

***

## v0.13.1-patch.1

<Callout type="note" title="Стабильный выпуск · Опубликован 2026-04-25 13:27:23 (время Китая)">
  ### Главное

  Патч добавляет поддержку `len` в условиях тарифов и помощнике запросов LLM для правил по длине ввода.

  ### Новые возможности

  * Добавлена переменная `len` в условия тарифов и помощник LLM для правил на основе длины ввода.

  ***

  **Полный список изменений**\: [https\://github.com/QuantumNous/new-api/compare/v0.13.1...v0.13.1-patch.1](https\://github.com/QuantumNous/new-api/compare/v0.13.1...v0.13.1-patch.1)

  **Загрузки**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/checksums-linux.txt) (186 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/checksums-macos.txt) (96 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/checksums-windows.txt) (94 B)
  * [new-api-arm64-v0.13.1-patch.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/new-api-arm64-v0.13.1-patch.1) (64.6 MB)
  * [new-api-macos-v0.13.1-patch.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/new-api-macos-v0.13.1-patch.1) (83.2 MB)
  * [new-api-v0.13.1-patch.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/new-api-v0.13.1-patch.1) (66.9 MB)
  * [new-api-v0.13.1-patch.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/new-api-v0.13.1-patch.1.exe) (68.6 MB)
  * [Исходный код (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.1-patch.1.zip)
  * [Исходный код (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.1-patch.1.tar.gz)
</Callout>

***

## v0.13.1

<Callout type="note" title="Стабильный выпуск · Опубликован 2026-04-24 22:20:58 (время Китая)">
  #### Новые возможности

  * Добавлена обработка суффиксов рассуждений DeepSeek V4 (#4428)

  #### Исправления

  * Модели многоуровневых тарифов больше не исключаются из списка (#4431)

  ***

  ### Изменения

  * fix\: модели многоуровневых тарифов в каталоге — @yyhhyyyyyy, [https\://github.com/QuantumNous/new-api/pull/4431](https\://github.com/QuantumNous/new-api/pull/4431)
  * feat\: обработка и тесты суффиксов рассуждений DeepSeek V4 — @HynoR, [https\://github.com/QuantumNous/new-api/pull/4428](https\://github.com/QuantumNous/new-api/pull/4428)

  **Полный список изменений**\: [https\://github.com/QuantumNous/new-api/compare/v0.13.0...v0.13.1](https\://github.com/QuantumNous/new-api/compare/v0.13.0...v0.13.1)

  **Загрузки**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/checksums-linux.txt) (170 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/checksums-macos.txt) (88 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/checksums-windows.txt) (86 B)
  * [New-API-App.0.13.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/New-API-App.0.13.1.exe) (106.5 MB)
  * [New-API-App.Setup.0.13.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/New-API-App.Setup.0.13.1.exe) (106.7 MB)
  * [new-api-arm64-v0.13.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/new-api-arm64-v0.13.1) (64.6 MB)
  * [new-api-macos-v0.13.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/new-api-macos-v0.13.1) (83.2 MB)
  * [new-api-v0.13.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/new-api-v0.13.1) (66.9 MB)
  * [new-api-v0.13.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/new-api-v0.13.1.exe) (68.6 MB)
  * [Исходный код (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.1.zip)
  * [Исходный код (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.1.tar.gz)
</Callout>

***

## v0.13.0

<Callout type="note" title="Стабильный выпуск · Опубликован 2026-04-24 14:09:21 (время Китая)">
  ### Главное

  Выпуск добавляет поддержку `expr` для выражений многоуровневых тарифов, позволяя задавать сложные динамические цены. Например, выражение `tokens <= 128000 ? 0.002 : 0.004` автоматически применяет низкую ставку до 128K токенов и высокую выше порога.

  ### Новые возможности

  * Добавлена обработка выражений `expr` в тарификации с динамическими уровнями и настраиваемыми шаблонами (#4409).
  * Добавлен интерфейс цен инструментов и улучшен расчет их квоты.
  * В счетах администратора за пополнение виден ID пользователя (#4349).
  * В таблицу токенов добавлено время последнего использования (#4372).
  * Ослаблен предел длины ключа для миграции старых длинных токенов (#4401).

  ### Исправления

  * Коэффициент N применяется при расчете только к графическим моделям (#4412).
  * Сохраняются надбавки текстовых инструментов при расчете многоуровневых тарифов (#4162).
  * Исправлен коэффициент выходных токенов модели `gpt-5.5` (#4414).
  * Исправлен тип отображения цен моделей (#4426).
  * Устранены сбои и крайние случаи редактора и расчета многоуровневых тарифов.
  * Тесты каналов правильно обрабатывают модели многоуровневых тарифов.

  ### Улучшения

  * Добавлены готовые уровни цен Doubao Seed 1.8 для расчета скидок.
  * Компоненты Card заменены на div для единого макета.
  * Внутренние расчеты используют квоту на единицу для точности.

  ***

  ### Изменения

  * fix(channel-test)\: тесты моделей многоуровневых тарифов — @yyhhyyyyyy, [https\://github.com/QuantumNous/new-api/pull/4145](https\://github.com/QuantumNous/new-api/pull/4145)
  * Показ ID пользователя в счетах пополнения администратора — @uskyu, [https\://github.com/QuantumNous/new-api/pull/4349](https\://github.com/QuantumNous/new-api/pull/4349)
  * Время последнего использования токена — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/4372](https\://github.com/QuantumNous/new-api/pull/4372)
  * chore(deps)\: обновление github.com/jackc/pgx/v5 с 5.9.0 до 5.9.2 — @dependabot\[bot], [https\://github.com/QuantumNous/new-api/pull/4397](https\://github.com/QuantumNous/new-api/pull/4397)
  * chore(deps-dev)\: обновление @xmldom/xmldom с 0.8.12 до 0.8.13 в /electron — @dependabot\[bot], [https\://github.com/QuantumNous/new-api/pull/4399](https\://github.com/QuantumNous/new-api/pull/4399)
  * Увеличение длины ключа токена для совместимости старой миграции — @XiaoAI1024, [https\://github.com/QuantumNous/new-api/pull/4401](https\://github.com/QuantumNous/new-api/pull/4401)
  * fix(billing)\: сохранение надбавок текстовых инструментов — @yyhhyyyyyy, [https\://github.com/QuantumNous/new-api/pull/4162](https\://github.com/QuantumNous/new-api/pull/4162)
  * feat\: выражения многоуровневых тарифов в расчетах — @Calcium-Ion, [https\://github.com/QuantumNous/new-api/pull/4409](https\://github.com/QuantumNous/new-api/pull/4409)
  * fix(image)\: коэффициент N только для графических моделей — @xyfacai, [https\://github.com/QuantumNous/new-api/pull/4412](https\://github.com/QuantumNous/new-api/pull/4412)
  * fix\: коэффициент выходных токенов gpt-5.5 — @jingx8885, [https\://github.com/QuantumNous/new-api/pull/4414](https\://github.com/QuantumNous/new-api/pull/4414)
  * fix\: правильный тип отображения цены модели — @feitianbubu, [https\://github.com/QuantumNous/new-api/pull/4426](https\://github.com/QuantumNous/new-api/pull/4426)

  ### Новые участники

  * @uskyu впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/4349](https\://github.com/QuantumNous/new-api/pull/4349)
  * @XiaoAI1024 впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/4401](https\://github.com/QuantumNous/new-api/pull/4401)
  * @jingx8885 впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/4414](https\://github.com/QuantumNous/new-api/pull/4414)

  **Полный список изменений**\: [https\://github.com/QuantumNous/new-api/compare/v0.12.15...v0.13.0](https\://github.com/QuantumNous/new-api/compare/v0.12.15...v0.13.0)

  **Загрузки**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/checksums-linux.txt) (170 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/checksums-macos.txt) (88 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/checksums-windows.txt) (86 B)
  * [New-API-App.0.13.0.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/New-API-App.0.13.0.exe) (106.5 MB)
  * [New-API-App.Setup.0.13.0.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/New-API-App.Setup.0.13.0.exe) (106.8 MB)
  * [new-api-arm64-v0.13.0](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/new-api-arm64-v0.13.0) (64.6 MB)
  * [new-api-macos-v0.13.0](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/new-api-macos-v0.13.0) (83.2 MB)
  * [new-api-v0.13.0](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/new-api-v0.13.0) (66.9 MB)
  * [new-api-v0.13.0.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/new-api-v0.13.0.exe) (68.6 MB)
  * [Исходный код (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.0.zip)
  * [Исходный код (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.0.tar.gz)
</Callout>

***

## v0.12.15

<Callout type="note" title="Стабильный выпуск · Опубликован 2026-04-22 23:04:03 (время Китая)">
  #### Новые возможности

  * Добавлена Waffo Pay для пополнения и платежных процессов (#4089).

  #### Исправления

  * Исправлена ошибка карточки пополнения, нарушавшая интерфейс (#4388).

  #### Улучшения

  * В Gemini добавлена поддержка настройки `IncludeServerSideToolInvocations` в `ToolConfig` для совместимости с новым вызовом инструментов (#4311).
  * Улучшены каналы Codex\: обновление учетных данных отключенных каналов, потоковые автотесты и окно потребления (#4324).

  ***

  ### Изменения

  * fix(gemini)\: поле IncludeServerSideToolInvocations в ToolConfig — @KoellM, [https\://github.com/QuantumNous/new-api/pull/4311](https\://github.com/QuantumNous/new-api/pull/4311)
  * refactor\: платежи — @seefs001, [https\://github.com/QuantumNous/new-api/pull/4089](https\://github.com/QuantumNous/new-api/pull/4089)
  * fix(topup)\: импорт отсутствующего Tag карточки пополнения — @gaoren002, `#4388`
  * chore\: макет окна потребления Codex — @seefs001, [https\://github.com/QuantumNous/new-api/pull/4386](https\://github.com/QuantumNous/new-api/pull/4386)
  * fix\: потоковый режим автоматического теста Codex — @seefs001, [https\://github.com/QuantumNous/new-api/pull/4325](https\://github.com/QuantumNous/new-api/pull/4325)
  * fix\: обновление учетных данных автоматически отключенных каналов Codex — @seefs001, [https\://github.com/QuantumNous/new-api/pull/4324](https\://github.com/QuantumNous/new-api/pull/4324)
  * fix\: обязательная проверка изменения passkey — @seefs001, [https\://github.com/QuantumNous/new-api/pull/4393](https\://github.com/QuantumNous/new-api/pull/4393)

  ### Новые участники

  * @KoellM впервые внес(ла) вклад\: [https\://github.com/QuantumNous/new-api/pull/4311](https\://github.com/QuantumNous/new-api/pull/4311)
  * @gaoren002 впервые внес(ла) вклад\: `#4388`

  **Полный список изменений**\: [https\://github.com/QuantumNous/new-api/compare/v0.12.14...v0.12.15](https\://github.com/QuantumNous/new-api/compare/v0.12.14...v0.12.15)

  **Загрузки**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/checksums-linux.txt) (172 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/checksums-macos.txt) (89 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/checksums-windows.txt) (87 B)
  * [New-API-App.0.12.15.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/New-API-App.0.12.15.exe) (106.3 MB)
  * [New-API-App.Setup.0.12.15.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/New-API-App.Setup.0.12.15.exe) (106.6 MB)
  * [new-api-arm64-v0.12.15](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/new-api-arm64-v0.12.15) (63.7 MB)
  * [new-api-macos-v0.12.15](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/new-api-macos-v0.12.15) (82.0 MB)
  * [new-api-v0.12.15](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/new-api-v0.12.15) (66.0 MB)
  * [new-api-v0.12.15.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/new-api-v0.12.15.exe) (67.7 MB)
  * [Исходный код (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.12.15.zip)
  * [Исходный код (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.12.15.tar.gz)
</Callout>

***