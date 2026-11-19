# Cherry Studio configuration

Cherry Studio is a desktop AI client supporting multiple providers. The following steps use a SimiRouter API key.

* Official Website\: [https\://cherry-ai.com](https\://cherry-ai.com/)
* Download Address\: [https\://cherry-ai.com/download](https\://cherry-ai.com/download)
* Documentation\: [https\://docs.cherry-ai.com](https\://docs.cherry-ai.com)

## Connect to SimiRouter

### Option 1\: Open from the key page

1. Install and start Cherry Studio, then find your key on the SimiRouter [API key management](https://api.dwchainless.com/keys) page.
2. Click **…** beside the key, select **Cherry Studio**, and allow the browser to open the application.
3. In Cherry Studio, check the imported API address, key, and model. The address should be `https://api.dwchainless.com`. Save and select a model available to your account.

### Option 2\: Configure manually

1. Open [API key management](https://api.dwchainless.com/keys) to copy the API key; you can also obtain the address from “Copy connection details” under **…** beside the key.
2. Open Cherry Studio **Settings → Model services**, and select **New API**. Set the API address to `https://api.dwchainless.com` and paste the key.
3. Click “Manage” to add or select an available model. Enable the provider and return to the chat page.

![Cherry Studio API address and key settings](/simidoc/assets/cherry_studio/simirouter-provider.png)

<Callout type="warn" title="Protect your key">
  Never expose keys in public screenshots or share them with untrusted applications. After a short test message, check the model and request in SimiRouter usage logs.
</Callout>

## Generate images in Cherry Studio

1. Add an image model available to your account whose API format Cherry Studio supports.![Cherry Studio image model settings](/simidoc/assets/cherry_studio/add_paint_models.png)

2. Select the model on the image page, enter a prompt, and inspect the generated result.![Cherry Studio image page and prompt input](/simidoc/assets/cherry_studio/paint.png)