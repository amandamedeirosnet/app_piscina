# 📱 Guia Passo a Passo: Gerar APK/AAB para Android

## ✅ Passo 1: Habilitar Modo de Desenvolvedor no Windows

1. **Abra as Configurações do Windows:**
   - Pressione `Windows + I`
   - Ou execute: `start ms-settings:developers`

2. **Ative o Modo de Desenvolvedor:**
   - Vá em **Configurações** → **Privacidade e Segurança** → **Para desenvolvedores**
   - Ative a opção **"Modo de Desenvolvedor"**
   - Se solicitado, confirme e **REINICIE** o computador

3. **Após reiniciar, teste novamente:**
   ```bash
   flutter clean
   flutter pub get
   ```

---

## ✅ Passo 2: Configurar Assinatura de Release (Keystore)

### 2.1. Gerar o Keystore

Execute no PowerShell (substitua o caminho se necessário):

```powershell
keytool -genkeypair -v -keystore C:\Users\Amanda\keystores\piscina-release.keystore -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias piscina
```

**Você será perguntado sobre:**
- **Senha do keystore**: Escolha uma senha forte e **GUARDE EM LUGAR SEGURO**
- **Senha da chave**: Pode ser a mesma do keystore ou diferente
- **Nome completo**: Seu nome
- **Unidade organizacional**: Ex: "Desenvolvimento"
- **Organização**: Ex: "Amanda"
- **Cidade**: Sua cidade
- **Estado**: Seu estado
- **Código do país**: Ex: "BR"

⚠️ **IMPORTANTE**: Guarde essas senhas! Você precisará delas para atualizar o app no futuro.

### 2.2. Criar o arquivo key.properties

1. **Crie a pasta `keystores` se não existir:**
   ```powershell
   mkdir C:\Users\Amanda\keystores
   ```

2. **Crie o arquivo `android/key.properties`** e preencha com:
   ```properties
   storePassword=SUA_SENHA_DO_STORE
   keyPassword=SUA_SENHA_DA_CHAVE
   keyAlias=piscina
   storeFile=C:\\Users\\Amanda\\keystores\\piscina-release.keystore
   ```

   ⚠️ **IMPORTANTE**: Use barras duplas (`\\`) no caminho no Windows!

3. **Adicione ao `.gitignore`** (se usar Git):
   ```
   android/key.properties
   android/**/key.properties
   *.keystore
   *.jks
   ```

---

## ✅ Passo 3: Verificar Configurações

O arquivo `android/app/build.gradle.kts` já está configurado com:
- ✅ `minSdk = 21` (Android 5.0+)
- ✅ `targetSdk = 34` (Android 14)
- ✅ `compileSdk = 34`
- ✅ Assinatura de release configurada

---

## ✅ Passo 4: Gerar o APK/AAB

### Opção A: APK (para instalação direta)

```powershell
cd "C:\Users\Amanda\Desktop\TCC AMANDA\app_elpool\app_piscina"
flutter clean
flutter pub get
flutter build apk --release
```

O APK estará em: `build\app\outputs\flutter-apk\app-release.apk`

### Opção B: AAB (para Google Play Store) ⭐ RECOMENDADO

```powershell
cd "C:\Users\Amanda\Desktop\TCC AMANDA\app_elpool\app_piscina"
flutter clean
flutter pub get
flutter build appbundle --release
```

O AAB estará em: `build\app\outputs\bundle\release\app-release.aab`

---

## ✅ Passo 5: Testar no Dispositivo

### Instalar APK via ADB:

1. **Conecte seu celular Android via USB**
2. **Ative o Modo de Desenvolvedor no celular:**
   - Vá em **Configurações** → **Sobre o telefone**
   - Toque 7 vezes em **"Número da compilação"**
3. **Ative a Depuração USB:**
   - **Configurações** → **Opções do desenvolvedor** → **Depuração USB**
4. **Instale o APK:**
   ```powershell
   adb install build\app\outputs\flutter-apk\app-release.apk
   ```

### Ou instale manualmente:
- Envie o arquivo `app-release.apk` para o celular
- Abra o arquivo no celular e instale
- Se pedir permissão para "Fontes desconhecidas", ative

---

## ✅ Passo 6: Publicar na Google Play Store

1. **Crie uma conta no Google Play Console:**
   - Acesse: https://play.google.com/console
   - Pague a taxa única de $25 USD

2. **Crie um novo app:**
   - Nome: "Piscina App"
   - Idioma padrão: Português (Brasil)
   - Tipo: App
   - Grátis ou Pago

3. **Envie o AAB:**
   - Vá em **Versão** → **Produção** (ou **Teste interno**)
   - Faça upload do arquivo `app-release.aab`
   - Preencha as informações:
     - O que há de novo nesta versão
     - Screenshots (obrigatório)
     - Ícone do app (512x512 px)
     - Descrição curta e longa
     - Política de privacidade (URL)

4. **Conteúdo do app:**
   - Classificação de conteúdo
   - Declaração de dados
   - Preços e distribuição

5. **Enviar para revisão:**
   - Após preencher tudo, clique em **"Enviar para revisão"**
   - O Google pode levar algumas horas/dias para aprovar

---

## 🔧 Solução de Problemas

### Erro: "Building with plugins requires symlink support"
✅ **Solução**: Habilite o Modo de Desenvolvedor (Passo 1)

### Erro: "SDK location not found"
✅ **Solução**: Abra o Android Studio e aceite as licenças:
```powershell
flutter doctor --android-licenses
```

### Erro: "Gradle build failed"
✅ **Solução**: 
```powershell
flutter clean
cd android
gradlew clean
cd ..
flutter pub get
flutter build apk --release
```

### Erro: "Keystore file not found"
✅ **Solução**: Verifique se o caminho em `key.properties` está correto com barras duplas (`\\`)

### Erro de permissões Bluetooth
✅ **Solução**: O app já tem as permissões no AndroidManifest.xml. Se não funcionar no Android 12+, você precisa pedir permissões em tempo de execução no código Dart.

---

## 📝 Checklist Final

Antes de publicar, verifique:

- [ ] Modo de Desenvolvedor ativado no Windows
- [ ] Keystore criado e guardado em local seguro
- [ ] Arquivo `key.properties` criado e configurado
- [ ] APK/AAB gerado com sucesso
- [ ] App testado em dispositivo real
- [ ] Bluetooth funcionando corretamente
- [ ] Todas as funcionalidades testadas
- [ ] Screenshots prontos para a Play Store
- [ ] Política de privacidade criada (se necessário)

---

## 🎉 Pronto!

Seu app está pronto para ser instalado ou publicado na Google Play Store!

**Dúvidas?** Verifique os logs de erro ou consulte a documentação do Flutter: https://docs.flutter.dev/deployment/android

