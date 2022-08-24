import { saveAs } from 'file-saver';

export const saveBlobAs = function (blob) {
    return function (name) {
        return function () {
            saveAs(blob, name);
        };
    };
};
