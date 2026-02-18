(function () {
	'use strict';

	/**
	  * Blazor javascript library v1.0.1 (https://github.com/czirok/devenv/)
	  * Copyright 2023-2026 Ferenc Czirok
	  * Licensed under MIT (https://github.com/czirok/devenv/blob/main/LICENSE)
	  */
	var __defProp$2 = Object.defineProperty;
	var __defNormalProp$2 = (obj, key, value) => key in obj ? __defProp$2(obj, key, { enumerable: true, configurable: true, writable: true, value }) : obj[key] = value;
	var __publicField$2 = (obj, key, value) => __defNormalProp$2(obj, typeof key !== "symbol" ? key + "" : key, value);
	class ChangeTheme {
	  constructor() {
	    __publicField$2(this, "THEME_STORAGE_NAME", "theme");
	    __publicField$2(this, "THEME_ATTRIBUTE", "data-bs-theme");
	    __publicField$2(this, "THEME_LIGHT", "light");
	    __publicField$2(this, "THEME_DARK", "dark");
	    __publicField$2(this, "THEME_AUTO", "auto");
	    __publicField$2(this, "dotNetObjRef");
	    __publicField$2(this, "_darkColorScheme");
	    this._darkColorScheme = window.matchMedia("(prefers-color-scheme: dark)");
	    this._keepYourEyesOnTheTheme();
	  }
	  get _systemTheme() {
	    return this._darkColorScheme.matches ? this.THEME_DARK : this.THEME_LIGHT;
	  }
	  get _storageTheme() {
	    return localStorage.getItem(this.THEME_STORAGE_NAME);
	  }
	  get _htmlTheme() {
	    return document.documentElement.getAttribute(this.THEME_ATTRIBUTE);
	  }
	  setReference(dotNetObjRef) {
	    this.dotNetObjRef = dotNetObjRef;
	  }
	  getTheme() {
	    return this._storageTheme;
	  }
	  setTheme(theme) {
	    if (theme === this.THEME_AUTO)
	      this._setAllAndInvokeBlazor(theme, this._systemTheme, this.THEME_AUTO);
	    else
	      this._setAllAndInvokeBlazor(theme, theme, theme);
	  }
	  _keepYourEyesOnTheTheme() {
	    this._htmlElementChanged();
	    const htmlElementChanged = (mutationList) => {
	      for (const mutation of mutationList) {
	        if (mutation.type === "attributes" && mutation.attributeName === this.THEME_ATTRIBUTE)
	          this._htmlElementChanged();
	      }
	    };
	    const observer = new MutationObserver(htmlElementChanged);
	    observer.observe(document.documentElement, {
	      attributes: true,
	      childList: false,
	      characterData: false
	    });
	    const systemThemeChanged = async (dark) => {
	      if (dark.matches)
	        await this._systemThemeChanged(this.THEME_DARK);
	      else
	        await this._systemThemeChanged(this.THEME_LIGHT);
	    };
	    this._darkColorScheme.addEventListener("change", systemThemeChanged);
	  }
	  _htmlElementChanged() {
	    if (this._storageTheme) {
	      if (this._storageTheme === this.THEME_AUTO) {
	        if (this._htmlTheme !== this._systemTheme)
	          this._setHtmlAndInvokeBlazor(this._systemTheme, this.THEME_AUTO);
	      } else if (this._storageTheme !== this._htmlTheme) {
	        this._setHtmlAndInvokeBlazor(this._storageTheme, this._storageTheme);
	      }
	    } else {
	      this._setAllAndInvokeBlazor(this.THEME_AUTO, this._systemTheme, this.THEME_AUTO);
	    }
	  }
	  async _systemThemeChanged(newValue) {
	    if (this._storageTheme) {
	      if (this._storageTheme === this.THEME_AUTO && this._htmlTheme !== newValue)
	        await this._setHtmlAndInvokeBlazor(newValue, this.THEME_AUTO);
	    } else {
	      await this._setAllAndInvokeBlazor(this.THEME_AUTO, this._systemTheme, this.THEME_AUTO);
	    }
	  }
	  async _setHtmlAndInvokeBlazor(html, theme) {
	    document.documentElement.setAttribute(this.THEME_ATTRIBUTE, html);
	    await this.dotNetObjRef?.invokeMethodAsync("OnUpdate", theme);
	  }
	  async _setAllAndInvokeBlazor(storage, html, theme) {
	    document.documentElement.setAttribute(this.THEME_ATTRIBUTE, html);
	    localStorage.setItem(this.THEME_STORAGE_NAME, storage);
	    await this.dotNetObjRef?.invokeMethodAsync("OnUpdate", theme);
	  }
	}

	/**
	  * Blazor javascript library v1.0.1 (https://github.com/czirok/devenv/)
	  * Copyright 2023-2026 Ferenc Czirok
	  * Licensed under MIT (https://github.com/czirok/devenv/blob/main/LICENSE)
	  */
	var __defProp$1 = Object.defineProperty;
	var __defNormalProp$1 = (obj, key, value) => key in obj ? __defProp$1(obj, key, { enumerable: true, configurable: true, writable: true, value }) : obj[key] = value;
	var __publicField$1 = (obj, key, value) => __defNormalProp$1(obj, typeof key !== "symbol" ? key + "" : key, value);
	class CultureSelector {
	  constructor() {
	    __publicField$1(this, "CULTURE_COOKIE_NAME", window.BlazorCultureCookie);
	    __publicField$1(this, "CULTURE_STORAGE_KEY", window.BlazorCultureStorage);
	    __publicField$1(this, "DEFAULT_CULTURE", "en-US");
	    __publicField$1(this, "RTL_CSS_ID", window.BlazorRTLId ?? "rtl-css");
	    __publicField$1(this, "LTR_CSS_ID", window.BlazorLTRId ?? "ltr-css");
	    __publicField$1(this, "RTL_CULTURES", [
	      "ar",
	      "arc",
	      "dv",
	      "fa",
	      "ha",
	      "he",
	      "khw",
	      "ks",
	      "ku",
	      "ps",
	      "ur",
	      "yi",
	      "ug",
	      "sd",
	      "prs",
	      "az",
	      "nqo",
	      "rhg",
	      "syr",
	      "ff"
	    ]);
	    __publicField$1(this, "_currentCulture");
	    if (this.CULTURE_STORAGE_KEY) {
	      this._currentCulture = this._storageCulture || this._browserCulture;
	      this._setStorage(this._currentCulture);
	    } else {
	      this._currentCulture = this._cookieCulture || this._browserCulture;
	      this._setCookie(this._currentCulture);
	    }
	    window.BlazorCulture = this._currentCulture;
	    this._setHtmlAttributes(this._currentCulture);
	  }
	  get _browserCulture() {
	    return navigator.language || this.DEFAULT_CULTURE;
	  }
	  get _cookieCulture() {
	    const cookieValue = this._getCookie(this.CULTURE_COOKIE_NAME);
	    if (!cookieValue)
	      return null;
	    try {
	      const decoded = decodeURIComponent(cookieValue);
	      const match = decoded.match(/c=([^|]+)/);
	      return match ? match[1] : null;
	    } catch {
	      return null;
	    }
	  }
	  get _storageCulture() {
	    const storageValue = localStorage.getItem(this.CULTURE_STORAGE_KEY);
	    if (!storageValue)
	      return null;
	    try {
	      const match = storageValue.match(/c=([^|]+)/);
	      return match ? match[1] : null;
	    } catch {
	      return null;
	    }
	  }
	  getCookie() {
	    return this._currentCulture;
	  }
	  setCookie(culture) {
	    if (culture === this._currentCulture)
	      return;
	    this._currentCulture = culture;
	    if (this.CULTURE_STORAGE_KEY) {
	      this._setStorage(culture);
	    } else {
	      this._setCookie(culture);
	    }
	    window.BlazorCulture = culture;
	  }
	  getStorage() {
	    return this._currentCulture;
	  }
	  setStorage(culture) {
	    if (culture === this._currentCulture)
	      return;
	    this._currentCulture = culture;
	    if (this.CULTURE_STORAGE_KEY) {
	      this._setStorage(culture);
	    } else {
	      this._setCookie(culture);
	    }
	    window.BlazorCulture = culture;
	  }
	  _setHtmlAttributes(culture) {
	    document.documentElement.setAttribute("lang", culture);
	    const langCode = culture.split("-")[0];
	    const isRtl = this.RTL_CULTURES.includes(langCode);
	    document.documentElement.setAttribute("dir", isRtl ? "rtl" : "ltr");
	    const cssLink = document.getElementById(isRtl ? this.RTL_CSS_ID : this.LTR_CSS_ID);
	    if (cssLink) {
	      cssLink.disabled = false;
	    }
	  }
	  _setStorage(culture) {
	    const cultureValue = `c=${culture}|uic=${culture}`;
	    localStorage.setItem(this.CULTURE_STORAGE_KEY, cultureValue);
	  }
	  _setCookie(culture) {
	    const cookieValue = `c=${culture}|uic=${culture}`;
	    const encodedValue = encodeURIComponent(cookieValue);
	    document.cookie = `${this.CULTURE_COOKIE_NAME}=${encodedValue}`;
	  }
	  _getCookie(name) {
	    const nameEQ = `${name}=`;
	    const cookies = document.cookie.split(";");
	    for (let cookie of cookies) {
	      cookie = cookie.trim();
	      if (cookie.indexOf(nameEQ) === 0) {
	        return cookie.substring(nameEQ.length);
	      }
	    }
	    return null;
	  }
	}

	/**
	  * Blazor javascript library v1.0.1 (https://github.com/czirok/devenv/)
	  * Copyright 2023-2026 Ferenc Czirok
	  * Licensed under MIT (https://github.com/czirok/devenv/blob/main/LICENSE)
	  */
	var __defProp = Object.defineProperty;
	var __defNormalProp = (obj, key, value) => key in obj ? __defProp(obj, key, { enumerable: true, configurable: true, writable: true, value }) : obj[key] = value;
	var __publicField = (obj, key, value) => __defNormalProp(obj, typeof key !== "symbol" ? key + "" : key, value);
	class BlazorHead {
	  constructor() {
	    __publicField(this, "ChangeTheme");
	    __publicField(this, "CultureSelector");
	    this.ChangeTheme = new ChangeTheme();
	    this.CultureSelector = new CultureSelector();
	  }
	}
	window.BlazorHead = new BlazorHead();

})();
//# sourceMappingURL=blazor.web.head.js.map
