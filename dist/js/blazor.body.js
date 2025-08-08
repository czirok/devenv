(function () {
	'use strict';

	/**
	  * Blazor javascript library v1.0.0 (https://github.com/czirok/devenv/)
	  * Copyright 2023-2025 Ferenc Czirok
	  * Licensed under MIT (https://github.com/czirok/devenv/blob/main/LICENSE)
	  */
	var __defProp$2 = Object.defineProperty;
	var __defNormalProp$2 = (obj, key, value) => key in obj ? __defProp$2(obj, key, { enumerable: true, configurable: true, writable: true, value }) : obj[key] = value;
	var __publicField$2 = (obj, key, value) => __defNormalProp$2(obj, typeof key !== "symbol" ? key + "" : key, value);
	const _OffcanvasSwipe = class _OffcanvasSwipe {
	  constructor() {
	    __publicField$2(this, "swipeStartTime", /* @__PURE__ */ new Date(0));
	    __publicField$2(this, "swipeStartX", 0);
	    __publicField$2(this, "swipeStartY", 0);
	    __publicField$2(this, "swipeStartElement");
	    __publicField$2(this, "swipeElement");
	    __publicField$2(this, "offcanvasElement");
	    __publicField$2(this, "isInitialized", false);
	    __publicField$2(this, "isTouch", false);
	    // Bound event handlers to enable proper removal
	    __publicField$2(this, "boundHandlePointerDown");
	    __publicField$2(this, "boundHandlePointerUp");
	    __publicField$2(this, "boundHandleTouchStart");
	    __publicField$2(this, "boundHandleTouchEnd");
	    this.boundHandlePointerDown = this.handlePointerDown.bind(this);
	    this.boundHandlePointerUp = this.handlePointerUp.bind(this);
	    this.boundHandleTouchStart = this.handleTouchStart.bind(this);
	    this.boundHandleTouchEnd = this.handleTouchEnd.bind(this);
	  }
	  initialize(swipeAreaId, offcanvasId, isTouch) {
	    this.isTouch = isTouch;
	    this.swipeElement = document.getElementById(swipeAreaId);
	    this.offcanvasElement = document.getElementById(offcanvasId);
	    if (!this.swipeElement || !this.offcanvasElement) {
	      return false;
	    }
	    this.bindEvents();
	    this.isInitialized = true;
	    return true;
	  }
	  bindEvents() {
	    if (!this.swipeElement || !this.offcanvasElement)
	      return;
	    if (this.isTouch) {
	      this.swipeElement.addEventListener("touchstart", this.boundHandleTouchStart);
	      this.swipeElement.addEventListener("touchend", this.boundHandleTouchEnd);
	      this.offcanvasElement.addEventListener("touchstart", this.boundHandleTouchStart);
	      this.offcanvasElement.addEventListener("touchend", this.boundHandleTouchEnd);
	    } else {
	      this.swipeElement.addEventListener("pointerdown", this.boundHandlePointerDown);
	      this.swipeElement.addEventListener("pointerup", this.boundHandlePointerUp);
	      this.offcanvasElement.addEventListener("pointerdown", this.boundHandlePointerDown);
	      this.offcanvasElement.addEventListener("pointerup", this.boundHandlePointerUp);
	    }
	  }
	  handlePointerDown(e) {
	    e.stopPropagation();
	    if (!e.isPrimary)
	      return;
	    this.startSwipe(e.clientX, e.clientY, e.currentTarget);
	  }
	  handlePointerUp(e) {
	    e.stopPropagation();
	    if (!e.isPrimary)
	      return;
	    const moveX = e.clientX - this.swipeStartX;
	    const moveY = e.clientY - this.swipeStartY;
	    const elapsedTime = (/* @__PURE__ */ new Date()).getTime() - this.swipeStartTime.getTime();
	    this.processSwipe(moveX, moveY, elapsedTime, e.currentTarget);
	  }
	  handleTouchStart(e) {
	    e.stopPropagation();
	    if (!e.touches || e.touches.length === 0)
	      return;
	    this.startSwipe(e.touches[0].clientX, e.touches[0].clientY, e.currentTarget);
	  }
	  handleTouchEnd(e) {
	    e.stopPropagation();
	    if (!e.changedTouches || e.changedTouches.length === 0)
	      return;
	    const moveX = e.changedTouches[0].clientX - this.swipeStartX;
	    const moveY = e.changedTouches[0].clientY - this.swipeStartY;
	    const elapsedTime = (/* @__PURE__ */ new Date()).getTime() - this.swipeStartTime.getTime();
	    this.processSwipe(moveX, moveY, elapsedTime, e.currentTarget);
	  }
	  startSwipe(x, y, element) {
	    this.swipeStartX = x;
	    this.swipeStartY = y;
	    this.swipeStartTime = /* @__PURE__ */ new Date();
	    this.swipeStartElement = element;
	  }
	  processSwipe(moveX, moveY, elapsedTime, currentElement) {
	    if (Math.abs(moveX) > _OffcanvasSwipe.MinHorizontalMove && Math.abs(moveY) < _OffcanvasSwipe.MaxVerticalMove && elapsedTime < _OffcanvasSwipe.Millisecond) {
	      const angle = Math.abs(Math.atan2(moveY, moveX) * 180 / Math.PI);
	      if (angle <= 45 || angle >= 135) {
	        if (this.swipeStartElement !== currentElement) {
	          return;
	        }
	        const isMainArea = currentElement === this.swipeElement;
	        const isSidebarArea = currentElement === this.offcanvasElement;
	        const isRTL = document.documentElement.dir === "rtl" || document.dir === "rtl";
	        if (isMainArea) {
	          const shouldOpen = isRTL ? moveX < 0 : moveX > 0;
	          if (shouldOpen) {
	            this.showMenu();
	          }
	        } else if (isSidebarArea) {
	          const shouldClose = isRTL ? moveX > 0 : moveX < 0;
	          if (shouldClose) {
	            this.hideMenu();
	          }
	        }
	      }
	    }
	  }
	  hideMenu() {
	    if (!this.offcanvasElement)
	      return;
	    if (this.isOffcanvasActive(this.offcanvasElement)) {
	      const offcanvasInstance = window.bootstrap?.Offcanvas?.getInstance(this.offcanvasElement);
	      if (offcanvasInstance) {
	        offcanvasInstance.hide();
	      } else {
	        this.offcanvasElement.classList.remove("show");
	      }
	    }
	  }
	  showMenu() {
	    if (!this.offcanvasElement)
	      return;
	    if (this.isOffcanvasActive(this.offcanvasElement)) {
	      const offcanvasInstance = window.bootstrap?.Offcanvas?.getInstance(this.offcanvasElement) || new window.bootstrap.Offcanvas(this.offcanvasElement);
	      if (offcanvasInstance) {
	        offcanvasInstance.show();
	      } else {
	        this.offcanvasElement.classList.add("show");
	      }
	    }
	  }
	  isOffcanvasActive(offcanvasElement) {
	    const classList = offcanvasElement.classList;
	    const breakpoints = ["sm", "md", "lg", "xl", "xxl"];
	    const hasOffcanvasBreakpoint = breakpoints.some(
	      (bp) => classList.contains(`offcanvas-${bp}`)
	    );
	    if (!hasOffcanvasBreakpoint && classList.contains("offcanvas")) {
	      return true;
	    }
	    if (hasOffcanvasBreakpoint) {
	      const viewportWidth = window.innerWidth;
	      const breakpointValues = {
	        sm: 576,
	        md: 768,
	        lg: 992,
	        xl: 1200,
	        xxl: 1400
	      };
	      for (const bp of breakpoints) {
	        if (classList.contains(`offcanvas-${bp}`)) {
	          const isActive = viewportWidth < breakpointValues[bp];
	          return isActive;
	        }
	      }
	    }
	    return false;
	  }
	  dispose() {
	    if (this.isInitialized) {
	      if (this.isTouch) {
	        if (this.swipeElement) {
	          this.swipeElement.removeEventListener("touchstart", this.boundHandleTouchStart);
	          this.swipeElement.removeEventListener("touchend", this.boundHandleTouchEnd);
	        }
	        if (this.offcanvasElement) {
	          this.offcanvasElement.removeEventListener("touchstart", this.boundHandleTouchStart);
	          this.offcanvasElement.removeEventListener("touchend", this.boundHandleTouchEnd);
	        }
	      } else {
	        if (this.swipeElement) {
	          this.swipeElement.removeEventListener("pointerdown", this.boundHandlePointerDown);
	          this.swipeElement.removeEventListener("pointerup", this.boundHandlePointerUp);
	        }
	        if (this.offcanvasElement) {
	          this.offcanvasElement.removeEventListener("pointerdown", this.boundHandlePointerDown);
	          this.offcanvasElement.removeEventListener("pointerup", this.boundHandlePointerUp);
	        }
	      }
	      this.isInitialized = false;
	    }
	  }
	};
	__publicField$2(_OffcanvasSwipe, "MinHorizontalMove", 100);
	__publicField$2(_OffcanvasSwipe, "MaxVerticalMove", 50);
	__publicField$2(_OffcanvasSwipe, "Millisecond", 300);
	let OffcanvasSwipe = _OffcanvasSwipe;

	/**
	  * Blazor javascript library v1.0.0 (https://github.com/czirok/devenv/)
	  * Copyright 2023-2025 Ferenc Czirok
	  * Licensed under MIT (https://github.com/czirok/devenv/blob/main/LICENSE)
	  */
	var __defProp$1 = Object.defineProperty;
	var __defNormalProp$1 = (obj, key, value) => key in obj ? __defProp$1(obj, key, { enumerable: true, configurable: true, writable: true, value }) : obj[key] = value;
	var __publicField$1 = (obj, key, value) => __defNormalProp$1(obj, typeof key !== "symbol" ? key + "" : key, value);
	class BackToTop {
	  constructor() {
	    __publicField$1(this, "dotNetObjRef");
	    __publicField$1(this, "scrollEventHandler");
	    this.scrollEventHandler = async () => {
	      await this.dotNetObjRef?.invokeMethodAsync("OnUpdate", window.scrollY);
	    };
	  }
	  setReference(dotNetObjRef) {
	    this.dotNetObjRef = dotNetObjRef;
	    window.addEventListener("scroll", this.scrollEventHandler);
	    return window.scrollY;
	  }
	  scrollTop() {
	    document.body.scrollTop = 0;
	    document.documentElement.scrollTop = 0;
	  }
	  dispose() {
	    this.dotNetObjRef?.dispose();
	    window.removeEventListener("scroll", this.scrollEventHandler);
	  }
	}

	/**
	  * Blazor javascript library v1.0.0 (https://github.com/czirok/devenv/)
	  * Copyright 2023-2025 Ferenc Czirok
	  * Licensed under MIT (https://github.com/czirok/devenv/blob/main/LICENSE)
	  */
	var __defProp = Object.defineProperty;
	var __defNormalProp = (obj, key, value) => key in obj ? __defProp(obj, key, { enumerable: true, configurable: true, writable: true, value }) : obj[key] = value;
	var __publicField = (obj, key, value) => __defNormalProp(obj, typeof key !== "symbol" ? key + "" : key, value);
	class BlazorBody {
	  constructor() {
	    __publicField(this, "OffcanvasSwipe");
	    __publicField(this, "BackToTop");
	    this.OffcanvasSwipe = new OffcanvasSwipe();
	    this.BackToTop = new BackToTop();
	  }
	}
	window.BlazorBody = new BlazorBody();

})();
//# sourceMappingURL=blazor.body.js.map
