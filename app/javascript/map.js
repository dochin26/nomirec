let maps = {};
let geocoder;
let isInitialized = false;
let isGoogleMapsLoaded = false;

function initMap() {
    // 既に初期化済みの場合はスキップ
    if (isGoogleMapsLoaded) {
        console.log("Google Maps already initialized, skipping");
        return;
    }

    console.log("Google Maps API loaded");
    isGoogleMapsLoaded = true;

    // geocoderがまだ初期化されていない場合のみ初期化
    if (!geocoder && typeof google !== 'undefined' && google.maps) {
        geocoder = new google.maps.Geocoder();
    }

    // DOM要素とgonの準備を待つ
    setTimeout(function() {
        initializeMapFeatures();
    }, 100);
}

function initializeMapFeatures() {
    // data-map-container属性を持つ要素とid="map"の要素の両方を探す
    const mapContainers = document.querySelectorAll("[data-map-container]");
    const mapElements = document.querySelectorAll("#map");

    // 両方を結合してユニークな要素のみを取得
    const allMapElements = new Set([...mapContainers, ...mapElements]);

    if (allMapElements.size === 0) {
        console.log("No map elements found");
        return;
    }

    // 全てのmap要素を初期化
    allMapElements.forEach(function(mapElement) {
        const mapId = mapElement.dataset.mapId || mapElement.id || 'default';

        // 既に初期化済みの場合は既存のマーカーをクリア
        if (maps[mapId] && maps[mapId].marker) {
            maps[mapId].marker.setMap(null);
        }

        initializeSingleMap(mapElement, mapId);
    });

    isInitialized = true;
}

function initializeSingleMap(mapElement, mapId) {
    if (!mapElement) {
        return;
    }

    console.log("Initializing map for mapId:", mapId);

    // 緯度経度が存在するかチェック（show/editページ用）
    let initialCenter = { lat: 35.6812, lng: 139.7671 };
    let initialZoom = 15;
    let hasExistingLocation = false;
    let existingLat = null;
    let existingLng = null;

    if (typeof gon !== 'undefined' && gon.latitude && gon.longitude) {
        console.log("gon.latitude:", gon.latitude, "type:", typeof gon.latitude);
        console.log("gon.longitude:", gon.longitude, "type:", typeof gon.longitude);

        const lat = parseFloat(gon.latitude);
        const lng = parseFloat(gon.longitude);

        console.log("Parsed lat:", lat, "type:", typeof lat);
        console.log("Parsed lng:", lng, "type:", typeof lng);

        // 有効な緯度経度かチェック
        if (!isNaN(lat) && !isNaN(lng) && lat !== 0 && lng !== 0) {
            console.log("Loading existing location:", lat, lng);
            existingLat = lat;
            existingLng = lng;
            initialCenter = { lat: lat, lng: lng };
            hasExistingLocation = true;
        } else {
            console.log("Invalid lat/lng values");
        }
    } else {
        console.log("gon not defined or missing latitude/longitude");
    }

    // 地図の初期化
    const map = new google.maps.Map(mapElement, {
        zoom: initialZoom,
        center: initialCenter
    });

    // 地図とマーカーをmapsオブジェクトに保存
    maps[mapId] = {
        map: map,
        marker: null
    };

    console.log("Map created and stored for mapId:", mapId);

    // 既存の位置情報がある場合はマーカーを設置
    if (hasExistingLocation && existingLat !== null && existingLng !== null) {
        const location = new google.maps.LatLng(existingLat, existingLng);
        updateMapLocation(mapId, location, gon.address || "保存された場所");
    }

    // モーダル内の地図またはeditページの地図の場合、検索・現在地機能を初期化
    if (mapId === 'map-modal' || mapId === 'map') {
        // 住所検索機能の初期化
        setupAddressSearch(mapId);

        // 現在地ボタンの初期化
        setupCurrentLocationButton(mapId);

        // 地図クリックリスナーの初期化
        setupMapClickListener(mapId);

        // フォーム送信時のバリデーション初期化
        setupFormValidation(mapId);
    }

    isInitialized = true;
}

// Turbo対応: DOMContentLoadedとturbo:loadの両方で初期化
document.addEventListener('DOMContentLoaded', function() {
    if (typeof google !== 'undefined' && google.maps) {
        if (!geocoder) {
            geocoder = new google.maps.Geocoder();
        }
        initializeMapFeatures();
    }
});

document.addEventListener('turbo:load', function() {
    console.log("turbo:load event fired");
    // ページ遷移時にフォームバリデーションフラグをリセット
    formValidationInitialized = false;

    // 既存の地図とマーカーをクリアして完全にリセット
    Object.keys(maps).forEach(function(mapId) {
        if (maps[mapId] && maps[mapId].marker) {
            maps[mapId].marker.setMap(null);
        }
    });
    maps = {};

    if (typeof google !== 'undefined' && google.maps) {
        if (!geocoder) {
            geocoder = new google.maps.Geocoder();
        }
        // 少し遅延させてgonの値が確実に設定されるようにする
        setTimeout(function() {
            initializeMapFeatures();
        }, 50);
    }
});

// Turbo Frame対応: フレームのレンダリング後に初期化
document.addEventListener('turbo:frame-render', function() {
    // モーダル表示時にフォームバリデーションフラグをリセット
    modalFormValidationInitialized = false;

    if (typeof google !== 'undefined' && google.maps) {
        if (!geocoder) {
            geocoder = new google.maps.Geocoder();
        }
        initializeMapFeatures();
    }
});

// バリデーションエラー時の再レンダリング対応
document.addEventListener('turbo:render', function() {
    if (typeof google !== 'undefined' && google.maps) {
        if (!geocoder) {
            geocoder = new google.maps.Geocoder();
        }
        setTimeout(function() {
            initializeMapFeatures();
        }, 50);
    }
});

// Turbo Streamでのレンダリング対応（バリデーションエラー時）
document.addEventListener('turbo:before-stream-render', function() {
    // 次のフレームで初期化を実行
    setTimeout(function() {
        if (typeof google !== 'undefined' && google.maps) {
            if (!geocoder) {
                geocoder = new google.maps.Geocoder();
            }
            initializeMapFeatures();
        }
    }, 100);
});

// ========== 住所検索機能（検索ボタンで検索）==========
function setupAddressSearch(mapId) {
    // mapIdに応じてIDプレフィックスを決定
    const prefix = mapId === 'map-modal' ? 'modal-' : '';

    const addressInput = document.getElementById(prefix + 'address-input');
    const searchBtn = document.getElementById(prefix + 'address-search-btn');

    if (!addressInput || !searchBtn) {
        console.log("Address input or search button not found for mapId:", mapId);
        return;
    }

    // 既存のイベントリスナーを削除して重複を防ぐ
    const newBtn = searchBtn.cloneNode(true);
    searchBtn.parentNode.replaceChild(newBtn, searchBtn);

    // 検索ボタンクリックで検索
    newBtn.addEventListener('click', function() {
        const searchQuery = addressInput.value.trim();

        if (searchQuery) {
            searchAddress(mapId, searchQuery, prefix);
        }
    });

    // Enterキーで検索ボタンを動作させる（フォーム送信を防止）
    addressInput.addEventListener('keypress', function(event) {
        if (event.key === 'Enter') {
            event.preventDefault();
            const searchQuery = addressInput.value.trim();

            if (searchQuery) {
                searchAddress(mapId, searchQuery, prefix);
            }
        }
    });

    // クリアボタンの初期化
    setupAddressClearButton(prefix);
}

// ========== 住所クリアボタン機能 ==========
function setupAddressClearButton(prefix) {
    const clearBtn = document.getElementById(prefix + 'address-clear-btn');
    const addressInput = document.getElementById(prefix + 'address-input');

    if (!clearBtn || !addressInput) {
        return;
    }

    // 既存のイベントリスナーを削除して重複を防ぐ
    const newClearBtn = clearBtn.cloneNode(true);
    clearBtn.parentNode.replaceChild(newClearBtn, clearBtn);

    newClearBtn.addEventListener('click', function() {
        // 住所入力欄をクリア
        addressInput.value = '';

        // 緯度経度もクリア
        const latInput = document.getElementById(prefix + 'latitude-input');
        const lngInput = document.getElementById(prefix + 'longitude-input');
        if (latInput && lngInput) {
            latInput.value = '';
            lngInput.value = '';
        }

        // 入力欄にフォーカス
        addressInput.focus();

        console.log("Address cleared");
    });
}

function searchAddress(mapId, query, prefix) {
    if (!geocoder) {
        console.log("Geocoder not initialized");
        return;
    }

    console.log("Searching for:", query);

    geocoder.geocode({
        address: query,
        region: 'JP'
    }, (results, status) => {
        if (status === "OK" && results && results.length > 0) {
            const location = results[0].geometry.location;
            const address = results[0].formatted_address;

            console.log("Found location:", location.lat(), location.lng());

            // 住所欄を更新
            const addressInput = document.getElementById(prefix + 'address-input');
            if (addressInput) {
                addressInput.value = address;
            }

            // 地図とマーカーを更新
            updateMapLocation(mapId, location, address);

            // hidden fieldを更新
            updateLatLngFields(location.lat(), location.lng(), prefix);
        } else {
            console.log("Geocoding failed:", status);
            alert("住所が見つかりませんでした。別の検索語をお試しください。");

            // 検索失敗時は緯度経度をクリア
            const latInput = document.getElementById(prefix + 'latitude-input');
            const lngInput = document.getElementById(prefix + 'longitude-input');
            if (latInput && lngInput) {
                latInput.value = '';
                lngInput.value = '';
                console.log("Cleared latitude/longitude fields");
            }
        }
    });
}

// ========== 現在地取得機能 ==========
function setupCurrentLocationButton(mapId) {
    // mapIdに応じてIDプレフィックスを決定
    const prefix = mapId === 'map-modal' ? 'modal-' : '';

    const currentLocationBtn = document.getElementById(prefix + 'current-location-btn');

    if (!currentLocationBtn) {
        console.log("Current location button not found for mapId:", mapId);
        return;
    }

    // 既存のイベントリスナーを削除して重複を防ぐ
    const newBtn = currentLocationBtn.cloneNode(true);
    currentLocationBtn.parentNode.replaceChild(newBtn, currentLocationBtn);

    newBtn.addEventListener('click', function() {
        getCurrentLocation(mapId, prefix);
    });
}

function getCurrentLocation(mapId, prefix) {
    const addressInput = document.getElementById(prefix + 'address-input');
    const currentLocationBtn = document.getElementById(prefix + 'current-location-btn');

    if (!navigator.geolocation) {
        alert('お使いのブラウザは位置情報取得に対応していません。');
        return;
    }

    // ボタンをローディング状態に
    const originalText = currentLocationBtn.innerHTML;
    currentLocationBtn.disabled = true;
    currentLocationBtn.innerHTML = '<svg class="animate-spin h-5 w-5 mr-2" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg> 取得中...';

    navigator.geolocation.getCurrentPosition(
        function(position) {
            const lat = Number(position.coords.latitude);
            const lng = Number(position.coords.longitude);

            console.log("Current location:", lat, lng);
            console.log("Type check - lat:", typeof lat, "lng:", typeof lng);

            // Reverse Geocodingで住所を取得（LatLngLiteralを使用）
            geocoder.geocode({ location: { lat: lat, lng: lng } }, function(results, status) {
                if (status === 'OK' && results && results[0]) {
                    const address = results[0].formatted_address;
                    addressInput.value = address;

                    // updateMapLocation用にLatLngオブジェクトを作成
                    const location = new google.maps.LatLng(lat, lng);
                    updateMapLocation(mapId, location, address);
                    updateLatLngFields(lat, lng, prefix);
                } else {
                    alert('住所の取得に失敗しました。');
                }

                // ボタンを元に戻す
                currentLocationBtn.disabled = false;
                currentLocationBtn.innerHTML = originalText;
            });
        },
        function(error) {
            console.error('Geolocation error:', error);
            let errorMessage = '現在地の取得に失敗しました。';

            switch(error.code) {
                case error.PERMISSION_DENIED:
                    errorMessage = '位置情報の使用が許可されていません。ブラウザの設定を確認してください。';
                    break;
                case error.POSITION_UNAVAILABLE:
                    errorMessage = '位置情報が取得できませんでした。';
                    break;
                case error.TIMEOUT:
                    errorMessage = '位置情報の取得がタイムアウトしました。';
                    break;
            }

            alert(errorMessage);

            // ボタンを元に戻す
            currentLocationBtn.disabled = false;
            currentLocationBtn.innerHTML = originalText;
        },
        {
            enableHighAccuracy: true,
            timeout: 10000,
            maximumAge: 0
        }
    );
}

// ========== 地図クリックで住所入力 ==========
function setupMapClickListener(mapId) {
    if (!maps[mapId] || !maps[mapId].map) {
        console.log("Map not initialized for mapId:", mapId);
        return;
    }

    // mapIdに応じてIDプレフィックスを決定
    const prefix = mapId === 'map-modal' ? 'modal-' : '';

    maps[mapId].map.addListener('click', function(event) {
        const clickedLocation = event.latLng;
        const lat = clickedLocation.lat();
        const lng = clickedLocation.lng();

        console.log("Map clicked:", lat, lng);

        // Reverse Geocodingで住所を取得
        geocoder.geocode({ location: clickedLocation }, function(results, status) {
            if (status === 'OK' && results && results[0]) {
                const address = results[0].formatted_address;
                const addressInput = document.getElementById(prefix + 'address-input');

                if (addressInput) {
                    addressInput.value = address;
                }

                updateMapLocation(mapId, clickedLocation, address);
                updateLatLngFields(lat, lng, prefix);
            } else {
                alert('この場所の住所を取得できませんでした。');
            }
        });
    });
}

// ========== ヘルパー関数: 地図とマーカーの更新 ==========
function updateMapLocation(mapId, location, title) {
    if (!maps[mapId] || !maps[mapId].map) {
        console.log("Map not found for mapId:", mapId);
        return;
    }

    // 既存のマーカーを削除
    if (maps[mapId].marker) {
        maps[mapId].marker.setMap(null);
    }

    // 地図の中心を移動
    maps[mapId].map.setCenter(location);

    // 新しいマーカーを配置
    maps[mapId].marker = new google.maps.Marker({
        map: maps[mapId].map,
        position: location,
        title: title,
        animation: google.maps.Animation.DROP
    });
}

// ========== ヘルパー関数: hidden fieldの更新 ==========
function updateLatLngFields(lat, lng, prefix) {
    // prefixが未指定の場合は空文字
    prefix = prefix || '';

    const latInput = document.getElementById(prefix + 'latitude-input');
    const lngInput = document.getElementById(prefix + 'longitude-input');

    if (latInput && lngInput) {
        latInput.value = lat;
        lngInput.value = lng;
        console.log("Updated hidden fields:", lat, lng);
    } else {
        console.log("Latitude/Longitude input fields not found");
    }
}

// ========== フォーム送信時のバリデーション ==========
let formValidationInitialized = false;
let modalFormValidationInitialized = false;

function setupFormValidation(mapId) {
    // mapIdに応じてIDプレフィックスを決定
    const prefix = mapId === 'map-modal' ? 'modal-' : '';
    const isModal = mapId === 'map-modal';

    // 既に初期化済みの場合はスキップ
    if (isModal && modalFormValidationInitialized) {
        return;
    }
    if (!isModal && formValidationInitialized) {
        return;
    }

    // 緯度経度のinputがあるフォームを探す
    const latInput = document.getElementById(prefix + 'latitude-input');
    if (!latInput) {
        return;
    }

    const form = latInput.closest('form');
    if (!form) {
        return;
    }

    // フォーム送信時のバリデーション（イベントキャプチャを使用）
    form.addEventListener('submit', function(event) {
        const latitudeInput = document.getElementById(prefix + 'latitude-input');
        const longitudeInput = document.getElementById(prefix + 'longitude-input');

        if (latitudeInput && longitudeInput) {
            const lat = latitudeInput.value;
            const lng = longitudeInput.value;

            if (!lat || !lng || lat === '' || lng === '') {
                event.preventDefault();
                event.stopPropagation();
                alert('住所が設定されていません。検索ボタンを押すか、地図をクリックして住所を設定してください。');
                return false;
            }
        }
    }, true);

    if (isModal) {
        modalFormValidationInitialized = true;
    } else {
        formValidationInitialized = true;
    }
    console.log("Form validation initialized for:", mapId);
}

window.initMap = initMap;
