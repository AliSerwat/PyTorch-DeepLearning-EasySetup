# Welcome to My AI Learning Repo! 🌟🚀 [![Open in Studio](https://pl-bolts-doc-images.s3.us-east-2.amazonaws.com/app-2/studio-badge.svg)](https://lightning.ai/new?repo_url=https%3A%2F%2Fgithub.com%2FAliSerwat%2FEasy_setup_for_Deep_Learning_with_PyTorch)

📚 If you're new to AI and eager to learn, [**`PyTorch`**](https://pytorch.org/) is an excellent library to start with. For beginners, [**"Deep Learning for Coders with Fastai and PyTorch, 1st Edition"**](https://www.amazon.co.uk/Deep-Learning-Coders-fastai-PyTorch/dp/1492045527), along with the [**Practical Deep Learning for Coders YouTube playlist**](https://www.youtube.com/playlist?list=PLfYUBJiXbdtSvpQjSnJJ_PmDQB_VyT5iU) and its [**`website`**](https://course.fast.ai/), provide a basic introduction to AI topics.

⚙️ While [**`Fastai`**](https://github.com/fastai) simplifies [**`PyTorch`**](https://pytorch.org/) for newbies, it may not be suited for real-world projects due to maintenance problems between versions 1 and 2.

🖥️ To create an efficient environment for practicing the content of [**"Deep Learning with PyTorch, 1st Edition"**](https://www.amazon.co.uk/Deep-Learning-Pytorch-Eli-Stevens/dp/1617295264), consider utilizing a remote server. This technique avoids the complications of local machine setup and potential package conflicts, which are typical in resource-intensive activities like deep learning algorithms.

📦 The second part of the book entails downloading <u>[**66.7 gigabytes of data (Luna16 Dataset)**](https://luna16.grand-challenge.org/Download/)</u>, which requires around 220 gigabytes of storage for manipulating medical images.

🔧 To solve these obstacles, [**`lightning.ai`**](https://lightning.ai/docs/overview/getting-started) offers free remote servers with suitable processing power and storage. [**`lightning.ai`**](https://lightning.ai/docs/overview/getting-started) prevents the establishment of new Conda environments within their studios, however Docker containers give a rapid alternative to this issue.

🔍 During my study on the [**`PyTorch`**](https://pytorch.org/) medical imaging project, [**"Docker: Up & Running: Shipping Reliable Containers in Production, 3rd Edition"**](https://www.amazon.co.uk/Docker-Shipping-Reliable-Containers-Production-dp-1098131827/dp/1098131827/ref=dp_ob_image_bk) proved vital. Docker's isolation feature allows you to treat running containers as full OS environments, easing the installation and upgrading of programs and libraries.

# For getting started

1. **Click on the badge** (you need to create an account in [**`lightning.ai`**](https://lightning.ai/onboarding)).
2. **Clone my repository**:

```sh
git clone https://github.com/AliSerwat/PyTorch-DeepLearning-EasySetup.git
```

3. **Change `create_docker_image.sh`'s mode**:

```sh
chmod +x ~/PyTorch-DeepLearning-EasySetup/create_docker_image.sh
```

4. **Execute `create_docker_image.sh`**:

```sh
~/PyTorch-DeepLearning-EasySetup/create_docker_image.sh
```

# After Creating Executing the Container

There is a minor issue in the file `~/dlwpt-code/util/disk.py`:

1. **Open the file in your editor**:

   ```sh
   code ~/dlwpt-code/util/disk.py
   ```

2. **Replace the following lines**:

   ```python
   import gzip

   from diskcache import FanoutCache, Disk
   from diskcache.core import BytesType, MODE_BINARY, BytesIO

   from util.logconf import logging
   log = logging.getLogger(__name__)
   # log.setLevel(logging.WARN)
   log.setLevel(logging.INFO)
   # log.setLevel(logging.DEBUG)
   ```

   **with**:

   ```python
   from util.logconf import logging
   import io
   import gzip

   from diskcache import FanoutCache, Disk
   # delete BytesType and BytesIO declarations
   from diskcache.core import MODE_BINARY

   BytesType = bytes  # Import them by ourselves
   BytesIO = io.BytesIO

   log = logging.getLogger(__name__)
   # log.setLevel(logging.WARN)
   log.setLevel(logging.INFO)
   # log.setLevel(logging.DEBUG)
   ```

# Overcoming Internet Connectivity Restrictions in Iran 🌐🔓

Due to internet connectivity restrictions in Iran, including filtering and sanctions, I want to share how to overcome these challenges.

⚡ AI has brought tremendous potential to our lives, requiring minimal resources compared to other emerging fields. However, conducting original research projects can be challenging due to budget and resource scarcity in many fields.

Since the infrastructure for AI development is accessible remotely and freely, I want to emphasize this opportunity. It allows your talents and potential to flourish despite circumstances beyond your control, such as where you were born.

### All you need is a PC, a stable, unlimited internet connection, and a phone number for verification

1. 🌍 **VPN for accessing unlimited connection:** Purchase VPN plans tailored to your needs from [**`this Telegram bot`**](https://t.me/MMDLeecherNimBot), which offers helpful tutorials (I typically use a Great Britain IP address to bypass restrictions).
2. 📞 **Purchase a single-use virtual phone number from** [`numberland.ir`](https://numberland.ir/). I bought an inexpensive England number to verify my [**`lightning.ai account`**](https://lightning.ai/onboarding). ⚠️ Ensure your VPN's IP address and the number's origin country match to avoid discrepancies.

### PS: You can also use [**`numberland.ir's numbers`**](https://numberland.ir/) to verify your [**`Kaggle account`**](https://www.kaggle.com/)
