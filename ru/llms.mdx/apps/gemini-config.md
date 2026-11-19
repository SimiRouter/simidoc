# Настройка Gemini CLI

Переменные окружения направляют Gemini CLI на платформу SimiRouter.

## macOS / Linux

**Временно, для текущего терминала\:**

```bash
export GOOGLE_GEMINI_BASE_URL="https://api.dwchainless.com"
export GEMINI_API_KEY="PASTE_API_KEY_HERE"
```

**Постоянно, с добавлением в конфигурацию оболочки\:**

```bash
install -d -m 700 ~/.config
umask 077
printf '%s\n' \
  'export GOOGLE_GEMINI_BASE_URL="https://api.dwchainless.com"' \
  'export GEMINI_API_KEY="PASTE_API_KEY_HERE"' > ~/.config/simiroouter.env
chmod 600 ~/.config/simiroouter.env
# Add this line to ~/.zshrc or ~/.bashrc: source ~/.config/simiroouter.env
source ~/.config/simiroouter.env
```

<Callout type="info" title="">
  Ключ хранится с правами `600` в `~/.config/simiroouter.env`, а не в профиле shell, который выполняется при каждом входе. Добавьте `source ~/.config/simiroouter.env` в `~/.bashrc` или `~/.zshrc` для постоянного действия и закройте файл от других пользователей на общих машинах.
</Callout>

## Windows PowerShell

**Временно\:**

```powershell
$env:GOOGLE_GEMINI_BASE_URL="https://api.dwchainless.com"
$env:GEMINI_API_KEY="PASTE_API_KEY_HERE"
```

**Постоянно, через профиль PowerShell\:**

```powershell
Add-Content $PROFILE 'Set-Item -Path Env:GOOGLE_GEMINI_BASE_URL -Value "https://api.dwchainless.com"'
Add-Content $PROFILE 'Set-Item -Path Env:GEMINI_API_KEY -Value "PASTE_API_KEY_HERE"'
```

## Windows CMD

**Временно\:**

```cmd
set GOOGLE_GEMINI_BASE_URL=https://api.dwchainless.com
set GEMINI_API_KEY=PASTE_API_KEY_HERE
```

**Постоянно, через переменные пользователя\:**

1. Нажмите `Win + R`, введите `sysdm.cpl` и нажмите Enter
2. Выберите «Дополнительно» → «Переменные среды»
3. В пользовательских переменных нажмите «Создать» и добавьте `GOOGLE_GEMINI_BASE_URL` и `GEMINI_API_KEY`
4. Перезапустите терминал для применения переменных

## Проверка запуска

```bash
gemini
```

После запуска выберите аутентификацию ключом API и отправьте короткое сообщение, затем проверьте вызов в журнале SimiRouter. Открытие клиента еще не подтверждает соединение с API.

## Частые вопросы

**Сообщение `GEMINI_API_KEY` не задана?**

* Проверьте написание имени переменной
* В Windows после изменения системных переменных перезапустите терминал

**Тайм-аут или ошибка подключения?**

* Проверьте, что `GOOGLE_GEMINI_BASE_URL` не содержит лишнего конечного `/`
* Проверьте сетевое соединение
* Проверьте действительность и срок ключа API

## Официальные материалы

[Справочник конфигурации Gemini CLI](https\://geminicli.com/docs/reference/configuration/)\: параметр `GOOGLE_GEMINI_BASE_URL` переопределяет корневой адрес; SDK отдельно добавляет версию API и путь модели, поэтому здесь не добавляется `/v1`.