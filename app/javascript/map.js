let map;
let geocoder;
let currentMarker;

function initMap() {
    console.log("Google Maps API loaded");
    map = new google.maps.Map(document.getElementById("map"), {
        zoom: 15,
        center: { lat: 35.6812, lng: 139.7671 }
    });

    geocoder = new google.maps.Geocoder();

    console.log(gon.addresses);
    const address = gon.addresses || '東京駅';
    geocodeAddress(address);
    setupFormSubmission();
}

function setupFormSubmission() {
    const form = document.getElementById('address-form');
    const addressInput = document.getElementById('address-input');
    
    if (!form || !addressInput) {
        return;
    }
    
    form.addEventListener('submit', function(event) {
        event.preventDefault();
        
        const newAddress = addressInput.value.trim();
        
        if (newAddress) {
            geocodeAddress(newAddress);
        } else {
            alert("住所を入力してください");
        }
    });

    addressInput.addEventListener('keypress', function(event) {
        if (event.key === 'Enter') {
            event.preventDefault();
            form.dispatchEvent(new Event('submit'));
        }
    });
}

function geocodeAddress(address) {
    if (!geocoder) {
        return;
    }

    if (!address || address === '') {
        address = '東京駅';
    }

    geocoder.geocode({
        address: address,
        region: 'JP'
    }, (results, status) => {
        if (status === "OK" && results && results.length > 0) {
            const location = results[0].geometry.location;

            if (!map) {
                return;
            }

            if (currentMarker) {
                currentMarker.setMap(null);
            }

            map.setCenter(location);

            currentMarker = new google.maps.Marker({
                map: map,
                position: location,
                title: results[0].formatted_address
            });
        } else {
            alert("住所が見つかりませんでした");
        }
    });
}

window.initMap = initMap;