# Настройка Cherry Studio

Cherry Studio — настольный ИИ-клиент для разных провайдеров моделей. Ниже описано подключение с ключом API SimiRouter.

* Официальный сайт\: [https\://cherry-ai.com](https\://cherry-ai.com/)
* Загрузка\: [https\://cherry-ai.com/download](https\://cherry-ai.com/download)
* Документация\: [https\://docs.cherry-ai.com](https\://docs.cherry-ai.com)

## Подключение SimiRouter

### Способ 1\: открыть со страницы ключей

1. Установите и запустите Cherry Studio; в SimiRouter [Ключи API](https://api.dwchainless.com/keys) найдите нужный ключ.
2. Нажмите справа от ключа **…**, выберите **Cherry Studio** и разрешите браузеру открыть приложение при запросе.
3. В Cherry Studio проверьте импортированные адрес API, ключ и модель; адрес API должен быть `https://api.dwchainless.com`. Сохраните и выберите доступную модель.

### Способ 2\: ручная настройка

1. В разделе [Ключи API](https://api.dwchainless.com/keys) скопируйте ключ API; также через меню справа **…** можно скопировать сведения о подключении и адрес.
2. Откройте в Cherry Studio **Настройки → Сервисы моделей** и выберите **New API**. В поле адреса API укажите `https://api.dwchainless.com`, а в поле ключа вставьте скопированное значение.
3. Нажмите «Управление», добавьте или выберите доступную модель, включите провайдера и вернитесь к чату.

![Настройки адреса API и ключа Cherry Studio](/simidoc/assets/cherry_studio/simirouter-provider.png)

<Callout type="warn" title="Защита ключа">
  Не публикуйте ключ API на снимках экрана и не передавайте ненадежным приложениям. После короткого теста проверьте модель и вызов в журнале SimiRouter.
</Callout>

## Создание изображений в Cherry Studio

1. Добавьте модель генерации изображений, доступную учетной записи и поддерживаемую интерфейсом Cherry Studio
   ![Добавление модели изображений в Cherry Studio](/simidoc/assets/cherry_studio/add_paint_models.png)

2. На странице изображений выберите модель, введите запрос и проверьте результат.
   ![Страница генерации изображений и поле запроса Cherry Studio](/simidoc/assets/cherry_studio/paint.png)